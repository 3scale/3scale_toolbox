module ThreeScaleToolbox
  module Helper
    class << self
      def compare_hashes(first, second, keys)
        keys.map { |key| first.fetch(key, nil) } == keys.map { |key| second.fetch(key, nil) }
      end

      ##
      # Compute array difference with custom comparator
      def array_difference(ary, other_ary)
        ary.reject do |ary_elem|
          other_ary.find do |other_ary_elem|
            yield(ary_elem, other_ary_elem)
          end
        end
      end

      ##
      # Returns new hash object with not nil valid params
      def filter_params(valid_params, source)
        valid_params.each_with_object({}) do |key, target|
          target[key] = source[key] unless source[key].nil?
        end
      end

      def parse_uri(uri)
        # raises error when remote_str is not string, but object or something else.
        URI(uri)
      end

      def hash_deep_dup(hash)
        JSON.parse(JSON.generate(hash))
      end

      def service_invalid_deployment_option?(error)
        Array(Hash(error)['deployment_option']).any? do |msg|
          msg.match(/is not included in the list/)
        end
      end

      def system_name_already_taken_error?(error)
        Array(Hash(error)['system_name']).any? { |msg| msg.match(/has already been taken/) }
      end

      def period_already_taken_error?(error)
        Array(Hash(error)['period']).any? { |msg| msg.match(/has already been taken/) }
      end

      def application_plan_mapping(source_app_plans, target_app_plans)
        target_app_plans.map do |target|
          source = source_app_plans.find { |app_plan| app_plan.system_name == target.system_name }
          [source, target]
        end.reject { |key, _| key.nil? }
      end

      def random_lowercase_name(length=8)
        [*('a'..'z')].sample(length).join
      end

      def backend_metric_link_parser(link)
        return if link.nil?

        link.match(/admin\/api\/backend_apis\/(\d+)\/metrics/) { |m| m.captures[0] }
      end
    end

    class BooleanTransformer
      def call(param_str)
        raise ArgumentError unless param_str.is_a?(String)

        return true if true?(param_str)
        return false if false?(param_str)

        raise ArgumentError
      end

      def true?(param_str)
        case param_str
        when 'true', '1'
          true
        else
          false
        end
      end

      def false?(param_str)
        case param_str
        when 'false', '0'
          true
        else
          false
        end
      end
    end
  end
end
