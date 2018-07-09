require '3scale/api'
require 'uri'
require 'csv'

module ThreeScaleToolbox
  module Commands
    module ImportCSVCommand
      def self.import_csv_command
        Cri::Command.define do
          name        'csv'
          usage       'csv [options]'
          summary     '3scale CLI import csv'
          description '3scale CLI import csv tool'

          flag :h, :help, 'show help for this command' do |_, cmd|
            puts cmd.help
            exit 0
          end

          required  :d, :destination, 'Destination'
          required  :f, 'file', 'File'

          run do |opts, args, _|
            ImportCSVCommand.run opts, args
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

      def self.provider_key_from_url(url)
        URI(url).user
      end

      def self.endpoint_from_url(url)
        uri      = URI(url)
        uri.user = nil
        
        uri.to_s
      end

      def self.auth_app_key_according_service(service)
        case service['backend_version']
        when '1'
          'user_key'
        when '2'
          'app_id'
        when 'oauth'
          'oauth'
        end
      end

      def self.import_csv(destination, file_path)
        endpoint     = endpoint_from_url destination
        provider_key = provider_key_from_url destination

        client   = ThreeScale::API.new(endpoint: endpoint, provider_key: provider_key)
        data     = CSV.read file_path
        headings = data.shift
        services = {}
        stats    = { services: 0, metrics: 0, methods: 0 , mapping_rules: 0 }

        # prepare services data
        data.each do |row|
          service_name = row[headings.find_index('service_name')]
          item         = {}

          services[service_name] ||= {}
          services[service_name][:items] ||= []

          (headings - ['service_name']).each do |heading|
            item[heading] = row[headings.find_index(heading)]
          end

          services[service_name][:items].push item
        end

        services.keys.each do |service_name|
          # create service
          service = client.create_service name: service_name

          if service['errors'].nil?
            stats[:services] += 1
            puts "Service #{service_name} has been created."
          else
            abort "Service has not been saved. Errors: #{service['errors']}"
          end

          # find hits metric (default)
          hits_metric = client.list_metrics(service['id']).find do |metric| 
            metric['system_name'] == 'hits'
          end

          services[service_name][:items].each do |item|

            metric, method = {}
            
            case item['type']
            # create a metric
            when 'metric'
              metric = client.create_metric(service['id'], { 
                system_name:   item['endpoint_system_name'],
                friendly_name: item['endpoint_name'],
                unit:          'unit'
              })

              if metric['errors'].nil?
                stats[:metrics] += 1
                puts "Metric #{item['endpoint_name']} has been created."
              else
                puts "Metric has not been saved. Errors: #{metric['errors']}"
              end
            # create a method
            when 'method'
              method = client.create_method(service['id'], hits_metric['id'], { 
                system_name:   item['endpoint_system_name'],
                friendly_name: item['endpoint_name'],
                unit:          'unit'
              })

              if method['errors'].nil?
                stats[:methods] += 1
                puts "Method #{item['endpoint_name']} has been created."
              else
                puts "Method has not been saved. Errors: #{method['errors']}"
              end
            end

            # create a mapping rule
            if (metric_id = metric['id'] || method['id'])
              mapping_rule = client.create_mapping_rule(service['id'], {
                metric_id:          metric_id,
                pattern:            item['endpoint_path'],
                http_method:        item['endpoint_http_method'],
                metric_system_name: item['endpoint_system_name'],
                auth_app_key:       auth_app_key_according_service(service),
                delta:              1
              })

              if mapping_rule['errors'].nil?
                stats[:mapping_rules] += 1
                puts "Mapping rule #{item['endpoint_system_name']} has been created."
              else
                puts "Mapping rule has not been saved. Errors: #{mapping_rule['errors']}"
              end
            end
          end
        end

        puts "#{services.keys.count} services in CSV file"
        puts "#{stats[:services]} services have been created"
        puts "#{stats[:metrics]} metrics have been created"
        puts "#{stats[:methods]} methods have beeen created"
        puts "#{stats[:mapping_rules]} mapping rules have been created"
      end

      def self.run(opts, _)
        destination = fetch_required_option(opts, :destination)
        file_path = fetch_required_option(opts, :file)
        import_csv(destination, file_path)
      end
    end

    module ImportCommand
      def self.import_command
        Cri::Command.define do
          name        'import'
          usage       'import <command> [options]'
          summary     '3scale CLI import'
          description '3scale CLI import tools to manage your API from the terminal.'

          flag :h, :help, 'show help for this command' do |_, cmd|
            puts cmd.help
            exit 0
          end
        end
      end

    end

    def self.command_import_definition
      ImportCommand.import_command.tap { |command| command.add_command ImportCSVCommand.import_csv_command }
    end
  end
end
