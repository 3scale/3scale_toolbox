module ThreeScaleToolbox
  module OpenAPI
    ##
    #
    # OAS3 object
    # * OAS3.title -> string
    # * OAS3.description -> string
    # * OAS3.version -> string
    # * OAS3.base_path -> string
    # * OAS3.host -> string
    # * OAS3.scheme -> string
    # * OAS3.operation -> array of operation hash
    #   * operation hash properties
    #     * :verb
    #     * :path
    #     * :description
    #     * :operation_id
    # * OAS3.security ->  security hash
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
    # * OAS3.service_backend_version -> string ('1','2','oidc')
    # * OAS3.set_server_url -> def(spec, url)
    # * OAS3.set_oauth2_urls-> def(spec, scheme_id, authorization_url, token_url)
    class OAS3
      META_SCHEMA_PATH = File.expand_path('../../../resources/oas3_meta_schema.json', __dir__)

      def self.validate(raw)
        meta_schema = JSON.parse(File.read(META_SCHEMA_PATH))
        JSON::Validator.validate!(meta_schema, raw)
      end

      def self.build(path, raw, validate: true)
        self.validate(raw) if validate

        new(path, raw)
      end

      attr_reader :definition

      def title
        definition.info['title']
      end

      def description
        definition.info['description']
      end

      def version
        definition.info['version']
      end

      def base_path
        # If there are many? take first
        # From https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md#openapi-object
        # If the servers property is not provided, or is an empty array,
        # the default value would be a Server Object with a url value of /
        server_objects(&:path).first || '/'
      end

      def host
        # If there are many? take first
        server_objects do |url|
          # URI::HTTP is parent of URI::HTTPS, so both covered
          "#{url.host}:#{url.port}" if url.kind_of?(URI::HTTP)
        end.first
      end

      def scheme
        # If there are many? take first
        server_objects(&:scheme).first
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

      ##
      # Update given spec with urls
      # It is expected identified security scheme to be oauth2 type
      def set_oauth2_urls(spec, sec_scheme_id, authorization_url, token_url)
        sec_scheme_obj = spec.dig('components', 'securitySchemes', sec_scheme_id)
        if sec_scheme_obj.nil? || sec_scheme_obj['type'] != 'oauth2'
          raise ThreeScaleToolbox::Error, "Expected security scheme {#{sec_scheme_id}} not found or not oauth2"
        end

        sec_scheme_obj['flows'].each do |flow_key, flow_obj|
          flow_obj['authorizationUrl'] = authorization_url if %w[implicit authorizationCode].include?(flow_key)
          flow_obj['tokenUrl'] = token_url if %w[password clientCredentials authorizationCode].include?(flow_key)
        end
      end

      def set_server_url(spec, url)
        spec['servers'] = [{ 'url' => url }]
      end

      private

      def initialize(path, raw)
        parser = OasParser::Parser.new(path, raw).resolve
        @definition = OasParser::Definition.new(parser, path)
      end

      def server_objects
        servers.map do |s|
          yield Helper.parse_uri rendered_url(s)
        end
      end

      # OAS3 server object variable substitution
      def rendered_url(server_object)
        template = erbfying_template(server_object.fetch('url'))
        vars = server_object_variables(server_object['variables'])
        ERB.new(template).result(OpenStruct.new(vars).instance_eval { binding })
      end

      def server_object_variables(variables)
        vars = (variables || {}).each_with_object({}) do |(key, value), a|
          a[key] = value['default']
        end
        JSON.parse(vars.to_json, symbolize_names: true)
      end

      def erbfying_template(template)
        # A URL is composed from a limited set of characters belonging to the US-ASCII character set.
        # These characters include digits (0-9), letters(A-Z, a-z), and a few special characters ("-", ".", "_", "~").
        # https://www.urlencoder.io/learn/
        tmp = template.gsub '{', '<%='
        tmp.gsub '}', '%>'
      end

      def servers
        definition.servers || []
      end

      def parse_operations
        definition.paths.flat_map do |path_obj|
          path_obj.endpoints.flat_map do |endpoint|
            {
              verb: endpoint.method,
              path: endpoint.path.path,
              description: endpoint.description,
              operation_id: endpoint.operationId
            }
          end
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
            sec_def = fetch_security_scheme(sec_item_name)
            {
              id: sec_item_name,
              type: sec_def['type'],
              name: sec_def['name'],
              in_f: sec_def['in'],
              flows: parse_flows(sec_def['flows']),
              scopes: sec_item
            }
          end
        end
      end

      def fetch_security_scheme(name)
        security_schemes.fetch(name) do |el|
          raise ThreeScaleToolbox::Error, "OAS3 parsing error: #{el} not found in security schemes"
        end
      end

      def security_requirements
        definition.security || []
      end

      def security_schemes
        (definition.components || {})['securitySchemes'] || {}
      end

      def parse_flows(flows_object)
        return nil if flows_object.nil?

        flows_object.keys.reduce(basic_flows_object) do |obj, key|
          obj.merge!(convert_flow(key) => true)
        end
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
        case flow_name
        when 'implicit'
          :implicit_flow_enabled
        when 'password'
          :direct_access_grants_enabled
        when 'clientCredentials'
          :service_accounts_enabled
        when 'authorizationCode'
          :standard_flow_enabled
        else
          raise ThreeScaleToolbox::Error, "Unexpected security flow field #{flow_name}"
        end
      end
    end
  end
end
