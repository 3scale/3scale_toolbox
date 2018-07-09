module ThreeScaleToolbox
  module Commands
    module CopyServiceCommand
      def self.service_command
        Cri::Command.define do
          name        'service'
          usage       'service [options] <service_id>'
          summary     '3scale CLI copy service'
          description '3scale CLI copy service tool'

          flag :h, :help, 'show help for this command' do |_, cmd|
            puts cmd.help
            exit 0
          end

          required  :s, :source, 'Source'
          required  :d, :destination, 'Destination'
          required  :t, 'target_system_name', 'Target system name'

          run do |opts, args, _|
            CopyServiceCommand.run opts, args
          end
        end
      end

      def self.run(opts, args)
        source      = fetch_required_option(opts, :source)
        destination = fetch_required_option(opts, :destination)
        system_name = fetch_required_option(opts, :target_system_name)
        exit_with_message 'error: missing service_id argument' if args.empty?
        service_id = args[0]
        copy_service(service_id, source, destination, system_name)
      end

      def self.exit_with_message(message)
        puts message
        exit 1
      end

      def self.fetch_required_option(options, key)
        options.fetch(key) { exit_with_message "error: Missing argument #{key}" }
      end

      def self.compare_hashes(first, second, keys)
        keys.map{ |key| first.fetch(key) } == keys.map{ |key| second.fetch(key) }
      end

      def self.provider_key_from_url(url)
        url[/\w*@/][0..-2]
      end

      def self.endpoint_from_url(url)
        url.sub /\w*@/, ''
      end

      def self.copy_service_params(original, system_name)
        {
          name:        original['name'],
          system_name: system_name,
          backend_version: original['backend_version'],
          end_user_registration_required: original['end_user_registration_required']
        }.reject { |key, value| !value }
      end

      def self.copy_service(service_id, source, destination, system_name)
        require '3scale/api'

        source_client = ThreeScale::API.new(
          endpoint:     endpoint_from_url(source),
          provider_key: provider_key_from_url(source)
        )
        client        = ThreeScale::API.new(
          endpoint:     endpoint_from_url(destination),
          provider_key: provider_key_from_url(destination)
        )

        service = source_client.show_service(service_id)
        copy    = client.create_service(copy_service_params(service, system_name))

        raise "Service has not been saved. Errors: #{copy['errors']}" unless copy['errors'].nil?

        service_copy_id = copy.fetch('id')

        puts "new service id #{service_copy_id}"

        proxy = source_client.show_proxy(service_id)
        client.update_proxy(service_copy_id, proxy)
        puts "updated proxy of #{service_copy_id} to match the original"

        metrics = source_client.list_metrics(service_id)
        metrics_copies = client.list_metrics(service_copy_id)

        hits = metrics.find{ |metric| metric['system_name'] == 'hits' } or raise 'missing hits metric'
        hits_copy = metrics_copies.find{ |metric| metric['system_name'] == 'hits' } or raise 'missing hits metric'

        methods = source_client.list_methods(service_id, hits['id'])
        methods_copies = client.list_methods(service_copy_id, hits_copy['id'])

        puts "original service hits metric #{hits['id']} has #{methods.size} methods"
        puts "copied service hits metric #{hits_copy['id']} has #{methods_copies.size} methods"

        missing_methods = methods.reject { |method|  methods_copies.find{|copy| compare_hashes(method, copy, ['system_name']) } }

        puts "creating #{missing_methods.size} missing methods on copied service"

        missing_methods.each do |method|
          copy = { friendly_name: method['friendly_name'], system_name: method['system_name'] }
          client.create_method(service_copy_id, hits_copy['id'], copy)
        end

        metrics_copies = client.list_metrics(service_copy_id)

        puts "original service has #{metrics.size} metrics"
        puts "copied service has #{metrics_copies.size} metrics"

        missing_metrics = metrics.reject { |metric| metrics_copies.find{|copy| compare_hashes(metric, copy, ['system_name']) } }

        missing_metrics.map do |metric|
          metric.delete('links')
          client.create_metric(service_copy_id, metric)
        end

        puts "created #{missing_metrics.size} metrics on the copied service"

        plans = source_client.list_service_application_plans(service_id)
        plan_copies = client.list_service_application_plans(service_copy_id)

        puts "original service has #{plans.size} application plans "
        puts "copied service has #{plan_copies.size} application plans"

        missing_application_plans = plans.reject { |plan| plan_copies.find{|copy| plan.fetch('system_name') == copy.fetch('system_name') } }

        puts "copied service missing #{missing_application_plans.size} application plans"

        missing_application_plans.each do |plan|
          plan.delete('links')
          plan.delete('default') # TODO: handle default plan

          if plan.delete('custom') # TODO: what to do with custom plans?
            puts "skipping custom plan #{plan}"
          else
            client.create_application_plan(service_copy_id, plan)
          end
        end

        application_plan_mapping = client.list_service_application_plans(service_copy_id).map do |plan_copy|
          plan = plans.find{|plan| plan.fetch('system_name') == plan_copy.fetch('system_name') }

          [plan['id'], plan_copy['id']]
        end

        metrics_mapping = client.list_metrics(service_copy_id).map do |copy|
          metric = metrics.find{|metric| metric.fetch('system_name') == copy.fetch('system_name') }
          metric ||= {}

          [metric['id'], copy['id']]
        end.to_h

        puts "destroying all mapping rules of the copy which have been created by default"
        client.list_mapping_rules(service_copy_id).each do |mapping_rule|
          client.delete_mapping_rule(service_copy_id, mapping_rule['id'])
        end

        mapping_rules = source_client.list_mapping_rules(service_id)
        mapping_rules_copy = client.list_mapping_rules(service_copy_id)

        puts "the original service has #{mapping_rules.size} mapping rules"
        puts "the copy has #{mapping_rules_copy.size} mapping rules"

        unique_mapping_rules_copy = mapping_rules_copy.dup

        missing_mapping_rules = mapping_rules.reject do |mapping_rule|
          matching_metric = unique_mapping_rules_copy.find do |copy|
            compare_hashes(mapping_rule, copy, %w(pattern http_method delta)) &&
                metrics_mapping.fetch(mapping_rule.fetch('metric_id')) == copy.fetch('metric_id')
          end

          unique_mapping_rules_copy.delete(matching_metric)
        end

        puts "missing #{missing_mapping_rules.size} mapping rules"

        missing_mapping_rules.each do |mapping_rule|
          mapping_rule.delete('links')
          mapping_rule['metric_id'] = metrics_mapping.fetch(mapping_rule.delete('metric_id'))
          client.create_mapping_rule(service_copy_id, mapping_rule)
        end
        puts "created #{missing_mapping_rules.size} mapping rules"

        puts "extra #{unique_mapping_rules_copy.size} mapping rules"
        puts unique_mapping_rules_copy.each{|rule| rule.delete('links') }

        application_plan_mapping.each do |original_id, copy_id|
          limits = source_client.list_application_plan_limits(original_id)
          limits_copy = client.list_application_plan_limits(copy_id)

          missing_limits = limits.reject { |limit| limits_copy.find{|limit_copy| limit.fetch('period') == limit_copy.fetch('period') } }

          missing_limits.each do |limit|
            limit.delete('links')
            client.create_application_plan_limit(copy_id, metrics_mapping.fetch(limit.fetch('metric_id')), limit)
          end
          puts "copied application plan #{copy_id} is missing #{missing_limits.size} from the original plan #{original_id}"
        end
      end
    end

    module CopyCommand
      def self.copy_command
        Cri::Command.define do
          name        'copy'
          usage       'copy <command> [options]'
          summary     '3scale CLI copy'
          description '3scale CLI copy tools to manage your API from the terminal.'

          flag :h, :help, 'show help for this command' do |_, cmd|
            puts cmd.help
            exit 0
          end
        end
      end
    end

    def self.command_copy_definition
      CopyCommand.copy_command.tap { |command| command.add_command CopyServiceCommand.service_command }
    end
  end
end
