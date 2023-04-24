module ThreeScaleToolbox
  module OpenAPI
    ##
    #
    # Swagger object
    # * Swagger.title -> string
    # * Swagger.description -> string
    # * Swagger.version -> string
    # * Swagger.basePath -> string
    # * Swagger.host -> string
    # * Swagger.scheme -> string
    # * Swagger.operation -> array of operation hash
    #   * operation hash properties
    #     * :verb
    #     * :path
    #     * :description
    #     * :operation_id
    # * Swagger.security ->  security hash
    #   * security hash properties
    #     * :id -> string
    #     * :type -> string
    #     * :name -> string
    #     * :in_f -> string
    #     * :flows -> hash
    #       * :implicit_flow_enabled -> bool
    #       * :direct_access_grants_enabled -> bool
    #       * :service_accounts_enabled -> bool
    #       * :standard_flow_enabled -> bool
    #     * :scopes -> array of string
    # * Swagger.service_backend_version -> string ('1','2','oidc')
    # * Swagger.set_server_url -> def(spec, url)
    # * Swagger.set_oauth2_urls-> def(spec, scheme_id, authorization_url, token_url)
    class Swagger
      META_SCHEMA_PATH = File.expand_path('../../../resources/swagger_meta_schema.json', __dir__)

      def self.validate(raw)
        meta_schema = JSON.parse(File.read(META_SCHEMA_PATH))
        JSON::Validator.validate!(meta_schema, raw)
      end

      def self.build(raw, validate: true)
        self.validate(raw) if validate

        new(raw)
      end

      attr_reader :raw

      def title
        raw.dig('info', 'title')
      end

      def description
        raw.dig('info', 'description')
      end

      def version
        raw.dig('info', 'version')
      end

      def base_path
        raw['basePath']
      end

      def host
        raw['host']
      end

      def scheme
        Array(raw['schemes']).first
      end

      def operations
        @operations ||= parse_operations
      end

      def security
        @security ||= parse_security
      end

      def service_backend_version
        # default authentication mode if no security requirement
        return '1' if security.nil?

        case security[:type]
        when 'oauth2'
          'oidc'
        when 'apiKey'
          '1'
        else
          raise ThreeScaleToolbox::Error, "Unexpected security scheme type #{security[:type]}"
        end
      end

      def set_server_url(spec, url)
        URI(url).tap do |uri|
          spec['host'] = "#{uri.host}:#{uri.port}"
          spec['schemes'] = [uri.scheme]
          spec['basePath'] = uri.path
        end
      end

      ##
      # Update given spec with urls
      # It is expected identified security scheme to be oauth2 type
      def set_oauth2_urls(spec, sec_scheme_id, authorization_url, token_url)
        sec_scheme_obj = spec.dig('securityDefinitions', sec_scheme_id)
        if sec_scheme_obj.nil? || sec_scheme_obj['type'] != 'oauth2'
          raise ThreeScaleToolbox::Error, "Expected security scheme {#{sec_scheme_id}} not found or not oauth2"
        end

        sec_scheme_obj['authorizationUrl'] = authorization_url if %w[implicit accessCode].include?(sec_scheme_obj['flow'])
        sec_scheme_obj['tokenUrl'] = token_url if %w[password application accessCode].include?(sec_scheme_obj['flow'])
      end

      private

      def initialize(raw)
        @raw = raw
      end

      def parse_operations
        raw['paths'].flat_map do |path, path_obj|
          path_obj.flat_map do |method, operation|
            next unless %w[get head post put patch delete trace options].include? method

            {
              verb: method,
              path: path,
              description: operation['description'],
              operation_id: operation['operationId']
            }
          end.compact
        end
      end

      def parse_security
        raise ThreeScaleToolbox::Error, 'Invalid OAS: multiple security requirements' \
          if global_security_requirements.size > 1

        global_security_requirements.first
      end

      def global_security_requirements
        @global_security_requirements ||= parse_global_security_reqs
      end

      def parse_global_security_reqs
        security_requirements.flat_map do |sec_req|
          sec_req.map do |sec_item_name, sec_item|
            sec_def = fetch_security_definition(sec_item_name)
            {
              id: sec_item_name,
              type: sec_def['type'],
              name: sec_def['name'],
              in_f: sec_def['in'],
              flows: parse_flows(sec_def['flow']),
              scopes: sec_item
            }
          end
        end
      end

      def fetch_security_definition(name)
        security_definitions.fetch(name) do |el|
          raise ThreeScaleToolbox::Error, "Swagger parsing error: #{el} not found in security definitions"
        end
      end

      def security_requirements
        raw['security'] || []
      end

      def security_definitions
        raw['securityDefinitions'] || {}
      end

      def parse_flows(flow_name)
        return nil if flow_name.nil?

        basic_flows_object.merge!({ convert_flow(flow_name) => true })
      end

      def basic_flows_object
        {
          standard_flow_enabled: false,
          implicit_flow_enabled: false,
          service_accounts_enabled: false,
          direct_access_grants_enabled: false
        }
      end

      def convert_flow(flow_name)
        return nil if flow_name.nil?

        case flow_name
        when 'implicit'
          :implicit_flow_enabled
        when 'password'
          :direct_access_grants_enabled
        when 'application'
          :service_accounts_enabled
        when 'accessCode'
          :standard_flow_enabled
        else
          raise ThreeScaleToolbox::Error, "Unexpected security flow field #{flow_name}"
        end
      end
    end
  end
end
