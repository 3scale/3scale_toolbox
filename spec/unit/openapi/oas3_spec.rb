RSpec.describe ThreeScaleToolbox::OpenAPI::OAS3 do
  include_context :oas3_resources

  let(:raw_specification) { YAML.safe_load(content) }
  let(:validate) { true }
  let(:path) { '/path/to/petstore.yaml' }
  subject { described_class.build(path, raw_specification, validate: validate) }
  let(:content) { basic_oas3_content }
  let(:basic_empty_flow) do
    {
      standard_flow_enabled: false, implicit_flow_enabled: false,
      service_accounts_enabled: false, direct_access_grants_enabled: false
    }
  end

  context 'missing info' do
    let(:content) do
      <<~YAML
        ---
        openapi: "3.0.0"
        paths:
          /pet:
            post:
              operationId: "addPet"
              responses:
                405:
                  description: "invalid input"
      YAML
    end

    it 'should raise error' do
      expect { subject }.to raise_error(JSON::Schema::ValidationError)
    end

    context 'but when validation skipped' do
      let(:validate) { false }

      it 'should not raise error' do
        expect { subject }.not_to raise_error
      end
    end
  end

  context 'missing paths' do
    let(:content) do
      <<~YAML
        ---
        openapi: "3.0.0"
        info:
          title: "sometitle"
          description: "some description"
          version: "1.0.0"
      YAML
    end

    it 'should raise error' do
      expect { subject }.to raise_error(JSON::Schema::ValidationError)
    end

    context 'but when validation skipped' do
      let(:validate) { false }

      it 'should not raise error' do
        expect { subject }.not_to raise_error
      end
    end
  end

  context '#scheme' do
    context 'missing servers' do
      let(:content) { basic_oas3_content }

      it 'empty array match' do
        expect(subject.scheme).to be_nil
      end
    end

    context 'parsed from servers list' do
      let(:content) { servers_oas3_content }

      it 'available' do
        expect(subject.scheme).to eq('https')
      end
    end
  end

  context '#base_path' do
    context 'missing servers' do
      let(:content) { basic_oas3_content }

      it 'should return /' do
        expect(subject.base_path).to eq('/')
      end
    end

    context 'parsed from servers list' do
      let(:content) { servers_oas3_content }

      it 'only first element taken' do
        expect(subject.base_path).to eq('/v1')
      end
    end

    context 'template servers' do
      let(:content) { server_templates_oas3_content }

      it 'template rendered' do
        expect(subject.base_path).to eq('/v1/petstorev1')
      end
    end
  end

  context '#host' do
    context 'missing servers' do
      let(:content) { basic_oas3_content }

      it 'should return /' do
        expect(subject.host).to be_nil
      end
    end

    context 'parsed from servers list' do
      let(:content) { servers_oas3_content }

      it 'only first element taken' do
        expect(subject.host).to eq('petstore.swagger.io:443')
      end
    end

    context 'includes port' do
      let(:content) { servers_port_oas3_content }

      it do
        expect(subject.host).to eq('petstore.swagger.io:8080')
      end
    end

    context 'template servers' do
      let(:content) { server_templates_oas3_content }

      it 'template rendered' do
        expect(subject.host).to eq('petstorev1.swagger.io:443')
      end
    end
  end

  context '#title' do
    let(:content) { basic_oas3_content }

    it 'available' do
      expect(subject.title).to eq('some title')
    end
  end

  context '#description' do
    let(:content) { basic_oas3_content }

    it 'available' do
      expect(subject.description).to eq('some description')
    end
  end

  context '#version' do
    let(:content) { basic_oas3_content }

    it 'available' do
      expect(subject.version).to eq('1.0.0')
    end
  end

  context '#operations' do
    let(:content) { basic_oas3_content }

    it 'available' do
      expect(subject.operations).not_to be_nil
    end

    it 'parsed as not empty' do
      expect(subject.operations).not_to be_empty
    end

    context 'operation' do
      let(:content) { basic_oas3_content }

      let(:get_pet_operation) do
        subject.operations.find { |op| op[:path] == '/pet' && op[:verb] == 'get' }
      end

      it 'available' do
        expect(get_pet_operation).not_to be_nil
      end

      it 'operationId matches' do
        expect(get_pet_operation[:operation_id]).to eq('getPet')
      end
    end

    context 'extensions in path object' do
      let(:content) { path_extensions_oas3_content }

      it 'parsed as not empty' do
        expect(subject.operations).not_to be_empty
      end

      it 'parsed single operation' do
        expect(subject.operations.size).to eq(1)
      end

      it 'parsed operation path /pet' do
        expect(subject.operations[0][:path]).to eq('/pet')
      end
      it 'parsed operation method get' do
        expect(subject.operations[0][:verb]).to eq('get')
      end
    end

    context 'parameters in path item object' do
      let(:content) { parameters_path_oas3_content }

      it 'parsed as not empty' do
        expect(subject.operations).not_to be_empty
      end

      it 'parsed single operation' do
        expect(subject.operations.size).to eq(1)
      end

      it 'parsed operation path /pet/{name}' do
        expect(subject.operations[0][:path]).to eq('/pet/{name}')
      end
      it 'parsed operation method get' do
        expect(subject.operations[0][:verb]).to eq('get')
      end
    end
  end

  context '#security' do
    context 'multiple sec schemas' do
      let(:content) { multiple_sec_schemas_oas3_content }

      it 'raises error' do
        expect { subject.security }.to raise_error(ThreeScaleToolbox::Error,
                                                   /Invalid OAS: multiple security requirements/)
      end
    end

    context 'apiKey Security type' do
      let(:content) { api_key_sec_oas3_content }

      it 'available' do
        expect(subject.security).not_to be_nil
      end

      it 'id matches' do
        expect(subject.security[:id]).to eq('petstore_api_key')
      end

      it 'type matches' do
        expect(subject.security[:type]).to eq('apiKey')
      end

      it 'name matches' do
        expect(subject.security[:name]).to eq('api_key')
      end

      it 'in_f matches' do
        expect(subject.security[:in_f]).to eq('header')
      end

      it 'flow matches' do
        expect(subject.security[:flows]).to be_nil
      end

      it 'scopes matches' do
        expect(subject.security[:scopes]).to be_empty
      end
    end

    context 'oauth2 implicit Security type' do
      let(:content) { oauth2_implicit_oas3_content }

      it 'available' do
        expect(subject.security).not_to be_nil
      end

      it 'id matches' do
        expect(subject.security[:id]).to eq('petstore_oauth')
      end

      it 'type matches' do
        expect(subject.security[:type]).to eq('oauth2')
      end

      it 'name matches' do
        expect(subject.security[:name]).to be_nil
      end

      it 'in_f matches' do
        expect(subject.security[:in_f]).to be_nil
      end

      it 'flow matches' do
        expect(subject.security[:flows]).to eq(basic_empty_flow.merge(implicit_flow_enabled: true))
      end

      it 'scopes matches' do
        expect(subject.security[:scopes]).to match_array(['write:pets', 'read:pets'])
      end
    end

    context 'oauth2 password Security type' do
      let(:content) { oauth2_password_oas3_content }

      it 'available' do
        expect(subject.security).not_to be_nil
      end

      it 'id matches' do
        expect(subject.security[:id]).to eq('petstore_oauth')
      end

      it 'type matches' do
        expect(subject.security[:type]).to eq('oauth2')
      end

      it 'name matches' do
        expect(subject.security[:name]).to be_nil
      end

      it 'in_f matches' do
        expect(subject.security[:in_f]).to be_nil
      end

      it 'flow matches' do
        expect(subject.security[:flows]).to eq(basic_empty_flow.merge(direct_access_grants_enabled: true))
      end

      it 'scopes matches' do
        expect(subject.security[:scopes]).to match_array(['write:pets', 'read:pets'])
      end
    end

    context 'oauth2 clientCredentials Security type' do
      let(:content) { oauth2_clientCredentials_oas3_content }

      it 'available' do
        expect(subject.security).not_to be_nil
      end

      it 'id matches' do
        expect(subject.security[:id]).to eq('petstore_oauth')
      end

      it 'type matches' do
        expect(subject.security[:type]).to eq('oauth2')
      end

      it 'name matches' do
        expect(subject.security[:name]).to be_nil
      end

      it 'in_f matches' do
        expect(subject.security[:in_f]).to be_nil
      end

      it 'flow matches' do
        expect(subject.security[:flows]).to eq(basic_empty_flow.merge(service_accounts_enabled: true))
      end

      it 'scopes matches' do
        expect(subject.security[:scopes]).to match_array(['write:pets', 'read:pets'])
      end
    end

    context 'oauth2 authorizationCode Security type' do
      let(:content) { oauth2_authorizationCode_oas3_content }

      it 'available' do
        expect(subject.security).not_to be_nil
      end

      it 'id matches' do
        expect(subject.security[:id]).to eq('petstore_oauth')
      end

      it 'type matches' do
        expect(subject.security[:type]).to eq('oauth2')
      end

      it 'name matches' do
        expect(subject.security[:name]).to be_nil
      end

      it 'in_f matches' do
        expect(subject.security[:in_f]).to be_nil
      end

      it 'flow matches' do
        expect(subject.security[:flows]).to eq(basic_empty_flow.merge(standard_flow_enabled: true))
      end

      it 'scopes matches' do
        expect(subject.security[:scopes]).to match_array(['write:pets', 'read:pets'])
      end
    end

    context 'missing security requirementes' do
      let(:content) do
        <<~YAML
          ---
          openapi: "3.0.0"
          info:
            title: "some title"
            version: "1.0.0"
          paths:
            /pet:
              get:
                operationId: "getPet"
                responses:
                  200:
                    description: "successful operation"
          components:
            securitySchemes:
              petstore_api_key:
                type: apiKey
                name: api_key
                in: header
        YAML
      end

      it 'not available' do
        expect(subject.security).to be_nil
      end
    end

    context 'missing security schemes' do
      let(:content) do
        <<~YAML
          ---
          openapi: "3.0.0"
          info:
            title: "some title"
            version: "1.0.0"
          paths:
            /pet:
              get:
                operationId: "getPet"
                responses:
                  200:
                    description: "successful operation"
          security:
            - petstore_oauth:
              - write:pets
              - read:pets
            - petstore_api_key: []
        YAML
      end

      it 'parsing raises error' do
        expect { subject.security }.to raise_error(ThreeScaleToolbox::Error,
                                                   /not found in security schemes/)
      end
    end

    context 'multiple flow security schema' do
      let(:content) { oauth2_multiple_flow_oas3_content }

      it 'matches oidc version' do
        expect(subject.service_backend_version).to eq('oidc')
      end

      it 'available' do
        expect(subject.security).not_to be_nil
      end

      it 'id matches' do
        expect(subject.security[:id]).to eq('petstore_oauth')
      end

      it 'type matches' do
        expect(subject.security[:type]).to eq('oauth2')
      end

      it 'name matches' do
        expect(subject.security[:name]).to be_nil
      end

      it 'in_f matches' do
        expect(subject.security[:in_f]).to be_nil
      end

      it 'flow matches' do
        expect(subject.security[:flows]).to eq(basic_empty_flow.merge({
                                                                       implicit_flow_enabled: true,
                                                                       direct_access_grants_enabled: true,
                                                                       service_accounts_enabled: true,
                                                                       standard_flow_enabled: true
                                                                     }))
      end

      it 'scopes matches' do
        expect(subject.security[:scopes]).to match_array(['write:pets', 'read:pets'])
      end
    end
  end

  context '#service_backend_version' do
    context 'missing security reqs' do
      let(:content) { basic_oas3_content }

      it 'matches apiKey version' do
        expect(subject.service_backend_version).to eq('1')
      end
    end

    context 'oauth2 security reqs' do
      let(:content) { oauth2_authorizationCode_oas3_content }

      it 'matches oidc version' do
        expect(subject.service_backend_version).to eq('oidc')
      end
    end

    context 'apiKey security reqs' do
      let(:content) { api_key_sec_oas3_content }

      it 'matches apiKey version' do
        expect(subject.service_backend_version).to eq('1')
      end
    end

    context 'basic security reqs' do
      let(:content) { basic_sec_oas3_content }

      it 'raises error' do
        expect { subject.service_backend_version }.to raise_error(ThreeScaleToolbox::Error,
                                                                  /security scheme type/)
      end
    end
  end

  context '#set_server_url' do
    let(:url) { 'https://newpetstore.example.org/v1' }

    context 'servers not in spec' do
      let(:activedocs) { YAML.safe_load(basic_oas3_content) }

      it 'server url set' do
        subject.set_server_url(activedocs, url)
        expect(activedocs['servers']).not_to be_empty
        expect(activedocs['servers'][0]['url']).to eq(url)
      end
    end

    context 'servers in spec' do
      let(:activedocs) { YAML.safe_load(servers_oas3_content) }

      it 'server url overrided' do
        subject.set_server_url(activedocs, url)
        expect(activedocs['servers']).not_to be_empty
        expect(activedocs['servers'][0]['url']).to eq(url)
      end
    end
  end

  context '#set_oauth2_urls' do
    let(:authorization_url) { 'https://sso.new_host.com:443/auth' }
    let(:token_url) { 'https://sso.new_host.com:443/token' }

    context 'implicit oauth' do
      let(:activedocs) { YAML.safe_load(oauth2_implicit_oas3_content) }

      it 'authorization set' do
        subject.set_oauth2_urls(activedocs, 'petstore_oauth', authorization_url, token_url)
        expect(activedocs.dig('components',
                              'securitySchemes',
                              'petstore_oauth',
                              'flows',
                              'implicit',
                              'authorizationUrl')).to eq(authorization_url)
      end
    end

    context 'password oauth' do
      let(:activedocs) { YAML.safe_load(oauth2_password_oas3_content) }

      it 'token url set' do
        subject.set_oauth2_urls(activedocs, 'petstore_oauth', authorization_url, token_url)
        expect(activedocs.dig('components',
                              'securitySchemes',
                              'petstore_oauth',
                              'flows',
                              'password',
                              'tokenUrl')).to eq(token_url)
      end
    end

    context 'clientCredentials oauth' do
      let(:activedocs) { YAML.safe_load(oauth2_clientCredentials_oas3_content) }

      it 'token url set' do
        subject.set_oauth2_urls(activedocs, 'petstore_oauth', authorization_url, token_url)
        expect(activedocs.dig('components',
                              'securitySchemes',
                              'petstore_oauth',
                              'flows',
                              'clientCredentials',
                              'tokenUrl')).to eq(token_url)
      end
    end

    context 'authorizationCode oauth' do
      let(:activedocs) { YAML.safe_load(oauth2_authorizationCode_oas3_content) }

      it 'token url set' do
        subject.set_oauth2_urls(activedocs, 'petstore_oauth', authorization_url, token_url)
        expect(activedocs.dig('components',
                              'securitySchemes',
                              'petstore_oauth',
                              'flows',
                              'authorizationCode',
                              'tokenUrl')).to eq(token_url)
      end

      it 'authorization set' do
        subject.set_oauth2_urls(activedocs, 'petstore_oauth', authorization_url, token_url)
        expect(activedocs.dig('components',
                              'securitySchemes',
                              'petstore_oauth',
                              'flows',
                              'authorizationCode',
                              'authorizationUrl')).to eq(authorization_url)
      end
    end
  end
end
