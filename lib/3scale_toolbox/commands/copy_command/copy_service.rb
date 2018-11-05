require 'cri'
require '3scale/api'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module CopyCommand
      class CopyServiceSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command
        include ThreeScaleToolbox::Remotes

        attr_reader :source, :destination, :system_name, :service_id,
                    :source_remote, :copy_remote,
                    :source_service, :copy_service,
                    :source_proxy,
                    :source_metrics, :copy_metrics,
                    :source_methods, :copy_methods,
                    :source_hits, :copy_hits,
                    :source_plans, :copy_plans,
                    :source_mapping_rules, :copy_mapping_rules,
                    :metrics_mapping,
                    :application_plan_mapping

        def self.command
          Cri::Command.define do
            name        'service'
            usage       'service [opts] -s <src> -d <dst> <service_id>'
            summary     'Copy service'
            description 'Will create a new services, copy existing proxy settings, metrics, methods, application plans and mapping rules.'

            option  :s, :source, '3scale source instance. Format: "http[s]://<provider_key>@3scale_url"', argument: :required
            option  :d, :destination, '3scale target instance. Format: "http[s]://<provider_key>@3scale_url"', argument: :required
            option  :t, 'target_system_name', 'Target system name', argument: :required
            param   :service_id

            runner CopyServiceSubcommand
          end
        end

        def run
          @source      = fetch_required_option(:source)
          @destination = fetch_required_option(:destination)
          @system_name = fetch_required_option(:target_system_name)
          @service_id = arguments[:service_id]

          process
        end

        private

        def create_remotes
          @source_remote = get_remote source
          @copy_remote = get_remote destination
        end

        def fetch_source_service
          @source_service = source_remote.show_service service_id
        end

        # Returns new hash object with not nil valid params
        def filter_params(valid_params, source)
          valid_params.each_with_object({}) do |key, target|
            target[key] = source[key] unless source[key].nil?
          end
        end

        def copy_service_params
          service_params = filter_params(Commands.service_valid_params,
                                         source_service)
          service_params.tap do |hash|
            hash['system_name'] = system_name if system_name
          end
        end

        def copy_service_id
          copy_service.fetch('id')
        end

        def create_service
          @copy_service = copy_remote.create_service copy_service_params
          errors = copy_service['errors']

          raise "Service has not been saved. Errors: #{errors}" unless errors.nil?
          puts "new service id #{copy_service_id}"
        end

        def fetch_source_proxy_settings
          @source_proxy = source_remote.show_proxy(service_id)
        end

        def create_proxy_settings
          copy_remote.update_proxy(copy_service_id, source_proxy)
          puts "updated proxy of #{copy_service_id} to match the original"
        end

        def fetch_source_metrics_methods
          @source_metrics = source_remote.list_metrics(service_id)
          @source_hits = source_metrics.find { |metric| metric['system_name'] == 'hits' } or raise 'missing hits metric'
          @source_methods = source_remote.list_methods(service_id, source_hits['id'])
          puts "original service hits metric #{source_hits['id']} has #{source_methods.size} methods"
        end

        def fetch_copy_metrics
          @copy_metrics = copy_remote.list_metrics(copy_service_id)
        end

        def fetch_copy_hits
          @copy_hits = copy_metrics.find { |metric| metric['system_name'] == 'hits' } or raise 'missing hits metric'
        end

        def fetch_copy_methods
          @copy_methods = copy_remote.list_methods(copy_service_id, copy_hits['id'])
        end

        def fetch_copy_metrics_methods
          fetch_copy_metrics
          fetch_copy_hits
          fetch_copy_methods
          puts "copied service hits metric #{copy_hits['id']} has #{copy_methods.size} methods"
        end

        def compare_hashes(first, second, keys)
          keys.map { |key| first.fetch(key) } == keys.map { |key| second.fetch(key) }
        end

        def missing_methods
          source_methods.reject do |method|
            copy_methods.find do |copy|
              compare_hashes(method, copy, ['system_name'])
            end
          end
        end

        def create_methods
          puts "creating #{missing_methods.size} missing methods on copied service"

          missing_methods.each do |method|
            copy = { friendly_name: method['friendly_name'], system_name: method['system_name'] }
            copy_remote.create_method(copy_service_id, copy_hits['id'], copy)
          end
        end

        def missing_metrics
          source_metrics.reject do |metric|
            copy_metrics.find do |copy|
              compare_hashes(metric, copy, ['system_name'])
            end
          end
        end

        def create_metrics
          puts "original service has #{source_metrics.size} metrics"
          puts "copied service has #{copy_metrics.size} metrics"

          missing_metrics.each do |metric|
            metric.delete('links')
            copy_remote.create_metric(copy_service_id, metric)
          end

          puts "created #{missing_metrics.size} metrics on the copied service"
        end

        def fetch_source_app_plans
          @source_plans = source_remote.list_service_application_plans service_id
          puts "original service has #{source_plans.size} application plans "
        end

        def fetch_copy_app_plans
          @copy_plans = copy_remote.list_service_application_plans copy_service_id
          puts "copied service has #{copy_plans.size} application plans"
        end

        def missing_app_plans
          source_plans.reject do |plan|
            copy_plans.find do |copy|
              plan.fetch('system_name') == copy.fetch('system_name')
            end
          end
        end

        def create_application_plans
          puts "copied service missing #{missing_app_plans.size} application plans"
          missing_app_plans.each do |plan|
            plan.delete('links')
            plan.delete('default') # TODO: handle default plan
            if plan.delete('custom') # TODO: what to do with custom plans?
              puts "skipping custom plan #{plan}"
            else
              copy_remote.create_application_plan(copy_service_id, plan)
            end
          end
        end

        def destroy_default_mapping_rules
          puts 'destroying all mapping rules of the copy which have been created by default'
          copy_remote.list_mapping_rules(copy_service_id).each do |mapping_rule|
            copy_remote.delete_mapping_rule(copy_service_id, mapping_rule['id'])
          end
        end

        def fetch_source_mapping_rules
          @source_mapping_rules = source_remote.list_mapping_rules(service_id)
          puts "the original service has #{source_mapping_rules.size} mapping rules"
        end

        def fetch_copy_mapping_rules
          @copy_mapping_rules = copy_remote.list_mapping_rules(copy_service_id)
          puts "the copy has #{copy_mapping_rules.size} mapping rules"
        end

        def create_metrics_mapping
          @metrics_mapping = copy_remote.list_metrics(copy_service_id).map do |copy|
            metric = source_metrics.find do |m|
              m.fetch('system_name') == copy.fetch('system_name')
            end
            metric ||= {}

            [metric['id'], copy['id']]
          end.to_h
        end

        def missing_mapping_rules
          source_mapping_rules.reject do |mapping_rule|
            copy_mapping_rules.find do |copy|
              compare_hashes(mapping_rule, copy, %w[pattern http_method delta]) &&
                metrics_mapping.fetch(mapping_rule.fetch('metric_id')) == copy.fetch('metric_id')
            end
          end
        end

        def create_mapping_rules
          puts "missing #{missing_mapping_rules.size} mapping rules"
          missing_mapping_rules.each do |mapping_rule|
            mapping_rule.delete('links')
            mapping_rule['metric_id'] = metrics_mapping.fetch(mapping_rule.delete('metric_id'))
            copy_remote.create_mapping_rule(copy_service_id, mapping_rule)
          end
          puts "created #{missing_mapping_rules.size} mapping rules"
        end

        def create_plan_mapping
          @application_plan_mapping = copy_remote.list_service_application_plans(copy_service_id).map do |plan_copy|
            plan = source_plans.find do |p|
              p.fetch('system_name') == plan_copy.fetch('system_name')
            end
            [plan['id'], plan_copy['id']]
          end
        end

        def missing_limits(limits, limits_copy)
          limits.reject do |limit|
            limits_copy.find do |limit_copy|
              limit.fetch('period') == limit_copy.fetch('period')
            end
          end
        end

        def create_limits
          application_plan_mapping.each do |original_id, copy_id|
            limits = source_remote.list_application_plan_limits(original_id)
            limits_copy = copy_remote.list_application_plan_limits(copy_id)

            m_l = missing_limits(limits, limits_copy)
            m_l.each do |limit|
              limit.delete('links')
              copy_remote.create_application_plan_limit(
                copy_id,
                metrics_mapping.fetch(limit.fetch('metric_id')),
                limit
              )
            end
            puts "copied application plan #{copy_id} is missing #{m_l.size} from the original " \
                 "plan #{original_id}"
          end
        end

        def process
          create_remotes
          fetch_source_service
          create_service
          fetch_source_proxy_settings
          create_proxy_settings
          fetch_source_metrics_methods
          fetch_copy_metrics_methods
          create_methods
          create_metrics
          create_metrics_mapping
          fetch_source_app_plans
          fetch_copy_app_plans
          create_application_plans
          destroy_default_mapping_rules
          fetch_source_mapping_rules
          fetch_copy_mapping_rules
          create_mapping_rules
          create_plan_mapping
          create_limits
        end
      end
    end
  end
end
