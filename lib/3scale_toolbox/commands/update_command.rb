require '3scale/api'
require 'uri'

module ThreeScaleToolbox
  module Commands
    module UpdateServiceCommand
      def self.update_service_command
        Cri::Command.define do
          name        'service'
          usage       'service [options] <service_id>'
          summary     '3scale CLI update service'
          description '3scale CLI update service tool'

          flag :h, :help, 'show help for this command' do |_, cmd|
            puts cmd.help
            exit 0
          end

          required  :s, :source, 'Source'
          required  :d, :destination, 'Destination'
          flag      :f, :force, 'Overwrites the mapping rules by deleting all rules from target service first'
          # TODO: parametrize what parts of service need to be copied
          flag      :r, 'rules-only', 'Updates only the mapping rules'

          run do |opts, args, _|
            UpdateServiceCommand.run opts, args
          end
        end
      end

      def self.exit_with_message(message)
        puts message
        exit 1
      end

      def self.fetch_required_option(options, key)
        options.fetch(key) { exit_with_message "error: Missing argument #{key}" }
      end

      class ServiceUpdater

        attr_reader :source_client, :target_client, :source_service_id, :target_service_id

        def initialize (source, source_service_id, destination, target_service_id)
          @source_client = ThreeScale::API.new(
            endpoint:     endpoint_from_url(source),
            provider_key: provider_key_from_url(source)
          )
          @target_client = ThreeScale::API.new(
            endpoint:     endpoint_from_url(destination),
            provider_key: provider_key_from_url(destination)
          )
          @source_service_id = source_service_id
          @target_service_id = target_service_id
        end

        def compare_hashes(first, second, keys)
          keys.map{ |key| first.fetch(key) } == keys.map{ |key| second.fetch(key) }
        end

        def provider_key_from_url(url)
          URI(url).user
        end

        def endpoint_from_url(url)
          uri      = URI(url)
          uri.user = nil

          uri.to_s
        end

        def target_service_params(source)
          # NOTE: backend_version and deployment_option are not yet returned by show_service method
          params = %w(name backend_version deployment_option end_user_registration_required)
          source.select { |k,v| params.include?(k) && v }
        end

        def source_metrics
          @source_metrics ||= source_client.list_metrics(source_service_id)
        end

        def metrics_mapping
          @metrics_mapping ||= target_client.list_metrics(target_service_id).map do |target|
            metric = source_metrics.find{|metric| metric.fetch('system_name') == target.fetch('system_name') }
            metric ||= {}

            [metric['id'], target['id']]
          end.to_h
        end

        def copy_service_settings
          source_service = source_client.show_service(source_service_id)
          puts "updating service settings for service id #{target_service_id}..."
          target_update_response = target_client.update_service(target_service_id, target_service_params(source_service))
          raise "Service has not been saved. Errors: #{target_update_response['errors']}" unless target_update_response['errors'].nil?
        end

        def copy_proxy_settings
          puts "updating proxy configuration for service id #{target_service_id}..."
          proxy = source_client.show_proxy(source_service_id)
          target_client.update_proxy(target_service_id, proxy)
          puts "updated proxy of #{target_service_id} to match the source #{source_service_id}"
        end

        def copy_metrics_and_methods
          target_metrics = target_client.list_metrics(target_service_id)

          source_hits = source_metrics.find{ |metric| metric['system_name'] == 'hits' } or raise 'missing hits metric'
          target_hits = target_metrics.find{ |metric| metric['system_name'] == 'hits' } or raise 'missing hits metric'

          source_methods = source_client.list_methods(source_service_id, source_hits['id'])
          target_methods = target_client.list_methods(target_service_id, target_hits['id'])

          puts "source service hits metric #{source_hits['id']} has #{source_methods.size} methods"
          puts "target service hits metric #{target_hits['id']} has #{target_methods.size} methods"

          missing_methods = source_methods.reject { |source_method|  target_methods.find{|target_method| compare_hashes(source_method, target_method, ['system_name']) } }

          puts "creating #{missing_methods.size} missing methods on target service..."
          missing_methods.each do |method|
            target = { friendly_name: method['friendly_name'], system_name: method['system_name'] }
            target_client.create_method(target_service_id, target_hits['id'], target)
          end

          target_metrics = target_client.list_metrics(target_service_id)

          puts "source service has #{source_metrics.size} metrics"
          puts "target service has #{target_metrics.size} metrics"

          missing_metrics = source_metrics.reject { |source_metric| target_metrics.find{|target_metric| compare_hashes(source_metric, target_metric, ['system_name']) } }

          missing_metrics.map do |metric|
            metric.delete('links')
            target_client.create_metric(target_service_id, metric)
          end

          puts "created #{missing_metrics.size} metrics on the target service"
        end

        def copy_application_plans
          source_plans = source_client.list_service_application_plans(source_service_id)
          target_plans = target_client.list_service_application_plans(target_service_id)

          puts "source service has #{source_plans.size} application plans"
          puts "target service has #{target_plans.size} application plans"

          missing_application_plans = source_plans.reject { |source_plan| target_plans.find{|target_plan| source_plan.fetch('system_name') == target_plan.fetch('system_name') } }

          puts "creating #{missing_application_plans.size} missing application plans..."

          missing_application_plans.each do |plan|
            plan.delete('links')
            plan.delete('default') # TODO: handle default plans

            if plan.delete('custom') # TODO: what to do with custom plans?
              puts "skipping custom plan #{plan}"
            else
              target_client.create_application_plan(target_service_id, plan)
            end
          end

          puts "updating limits for application plans..."

          application_plan_mapping = target_client.list_service_application_plans(target_service_id).map do |plan_target|
            plan = source_plans.find{|plan| plan.fetch('system_name') == plan_target.fetch('system_name') }
            plan ||= {}
            [plan['id'], plan_target['id']]
          end.to_h.reject { |key, value| !key }

          application_plan_mapping.each do |source_id, target_id|
            source_limits = source_client.list_application_plan_limits(source_id)
            target_limits = target_client.list_application_plan_limits(target_id)

            missing_limits = source_limits.reject { |limit| target_limits.find{|limit_target| limit.fetch('period') == limit_target.fetch('period') } }

            puts "target application plan #{target_id} is missing #{missing_limits.size} from the source plan #{source_id}"

            missing_limits.each do |limit|
              limit.delete('links')
              target_client.create_application_plan_limit(target_id, metrics_mapping.fetch(limit.fetch('metric_id')), limit)
            end

          end
        end

        def copy_mapping_rules force_mapping_rules
          source_mapping_rules = source_client.list_mapping_rules(source_service_id)
          target_mapping_rules = target_client.list_mapping_rules(target_service_id)

          puts "the source service has #{source_mapping_rules.size} mapping rules"
          puts "the target has #{target_mapping_rules.size} mapping rules"

          if force_mapping_rules
            puts "force mode was chosen, deleting existing mapping rules on target service..."
            target_mapping_rules.each do |rule|
              target_client.delete_mapping_rule(target_service_id, rule['id'])
            end
            missing_mapping_rules = source_mapping_rules
          else
            unique_target_mapping_rules = target_mapping_rules.dup

            missing_mapping_rules = source_mapping_rules.reject do |mapping_rule|
              matching_metric = unique_target_mapping_rules.find do |target|
                compare_hashes(mapping_rule, target, %w(pattern http_method delta)) &&
                    metrics_mapping.fetch(mapping_rule.fetch('metric_id')) == target.fetch('metric_id')
              end

              unique_target_mapping_rules.delete(matching_metric)
            end
          end

          puts "missing #{missing_mapping_rules.size} mapping rules"

          missing_mapping_rules.each do |mapping_rule|
            mapping_rule.delete('links')
            mapping_rule['metric_id'] = metrics_mapping.fetch(mapping_rule.delete('metric_id'))
            target_client.create_mapping_rule(target_service_id, mapping_rule)
          end
          puts "created #{missing_mapping_rules.size} mapping rules"
        end

        def update_service force_mapping_rules=false
          copy_service_settings
          copy_proxy_settings
          copy_metrics_and_methods
          copy_application_plans
          copy_mapping_rules force_mapping_rules
        end
      end

      def self.run(opts, args)
        source      = fetch_required_option(opts, :source)
        destination = fetch_required_option(opts, :destination)
        exit_with_message 'error: missing source_service_id argument' if args.empty?
        exit_with_message 'error: missing target_service_id argument' if args.size < 2
        source_service_id = args[0]
        target_service_id = args[1]
        force_update = opts[:force] || false
        rules_only = opts[:'rules-only'] || false
        updater = ServiceUpdater.new(source, source_service_id, destination, target_service_id)

        if rules_only
          updater.copy_mapping_rules force_update
        else
          updater.update_service force_update
        end
      end
    end
    module UpdateCommand
      def self.update_command
        Cri::Command.define do
          name        'update'
          usage       'update <command> [options]'
          summary     '3scale CLI update'
          description '3scale CLI update tools to manage your API from the terminal.'

          flag :h, :help, 'show help for this command' do |_, cmd|
            puts cmd.help
            exit 0
          end
        end
      end
    end
    def self.command_update_definition
      UpdateCommand.update_command.tap { |command| command.add_command UpdateServiceCommand.update_service_command }
    end
  end
end
