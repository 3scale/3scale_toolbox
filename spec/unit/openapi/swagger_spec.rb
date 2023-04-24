RSpec.describe ThreeScaleToolbox::OpenAPI::Swagger do
  include_context :swagger_resources

  let(:raw_specification) { YAML.safe_load(content) }
  let(:validate) { true }
  subject { described_class.build(raw_specification, validate: validate) }
  let(:content) { basic_swagger_content }
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
        swagger: "2.0"
        paths:
          /pet:
            post:
              operationId: "addPet"
              description: ""
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
        swagger: "2.0"
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
    context 'parsed from schemes field' do
      let(:content) { schemes_swagger_content }

      it 'available' do
        expect(subject.scheme).to eq('https')
      end
    end

    context 'missing schemes field' do
      let(:content) { basic_swagger_content }

      it 'empty array match' do
        expect(subject.scheme).to be_nil
      end
    end
  end

  context '#base_path' do
    context 'parsed from basePath' do
      let(:content) { base_path_swagger_content }

      it 'available' do
        expect(subject.base_path).to eq('/v1')
      end
    end

    context 'missing basePath' do
      let(:content) { basic_swagger_content }

      it 'should return nil' do
        expect(subject.base_path).to be_nil
      end
    end
  end

  context '#title' do
    let(:content) { basic_swagger_content }

    it 'available' do
      expect(subject.title).to eq('some title')
    end
  end

  context '#description' do
    let(:content) { basic_swagger_content }

    it 'available' do
      expect(subject.description).to eq('some description')
    end
  end

  context '#version' do
    let(:content) { basic_swagger_content }

    it 'available' do
      expect(subject.version).to eq('1.0.0')
    end
  end

  context 'operations' do
    let(:content) { basic_swagger_content }

    it 'available' do
      expect(subject.operations).not_to be_nil
    end

    it 'parsed as not empty' do
      expect(subject.operations).not_to be_empty
    end

    context 'operation' do
      let(:content) { basic_swagger_content }

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
      let(:content) { path_extensions_swagger_content }

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
      let(:content) { parameters_path_swagger_content }

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
      let(:content) { multiple_sec_reqs_swagger_content }

      it 'raises error' do
        expect { subject.security }.to raise_error(ThreeScaleToolbox::Error,
                                                   /Invalid OAS: multiple security requirements/)
      end
    end

    context 'apiKey Security type' do
      let(:content) { api_key_sec_swagger_content }

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
      let(:content) { oauth2_implicit_swagger_content }

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
      let(:content) { oauth2_password_swagger_content }

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

    context 'oauth2 application Security type' do
      let(:content) { oauth2_application_swagger_content }

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

    context 'oauth2 accessCode Security type' do
      let(:content) { oauth2_accessCode_swagger_content }

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
          swagger: "2.0"
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
          securityDefinitions:
            LegacySecurity:
              type: basic
        YAML
      end

      it 'not available' do
        expect(subject.security).to be_nil
      end
    end

    context 'missing security definitions' do
      let(:content) do
        <<~YAML
          ---
          swagger: "2.0"
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
            - MediaSecurity: []
        YAML
      end

      it 'parsing raises error' do
        expect { subject.security }.to raise_error(ThreeScaleToolbox::Error,
                                                   /not found in security definitions/)
      end
    end
  end

  context '#service_backend_version' do
    context 'missing security reqs' do
      let(:content) { basic_swagger_content }

      it 'matches apiKey version' do
        expect(subject.service_backend_version).to eq('1')
      end
    end

    context 'oauth2 security reqs' do
      let(:content) { oauth2_accessCode_swagger_content }

      it 'matches oidc version' do
        expect(subject.service_backend_version).to eq('oidc')
      end
    end

    context 'apiKey security reqs' do
      let(:content) { api_key_sec_swagger_content }

      it 'matches apiKey version' do
        expect(subject.service_backend_version).to eq('1')
      end
    end

    context 'basic security reqs' do
      let(:content) { basic_sec_swagger_content }

      it 'raises error' do
        expect { subject.service_backend_version }.to raise_error(ThreeScaleToolbox::Error,
                                                                  /security scheme type/)
      end
    end
  end

  context '#set_server_url' do
    let(:url) { 'https://newpetstore.example.org/v11111' }
    let(:url_obj) { URI(url) }

    context 'host not in spec' do
      let(:activedocs) { YAML.safe_load(basic_swagger_content) }

      it 'host set' do
        subject.set_server_url(activedocs, url)
        expect(activedocs['host']).to eq("#{url_obj.host}:#{url_obj.port}")
      end
    end

    context 'host in spec' do
      let(:activedocs) { YAML.safe_load(host_swagger_content) }

      it 'host overrided' do
        subject.set_server_url(activedocs, url)
        expect(activedocs['host']).to eq("#{url_obj.host}:#{url_obj.port}")
      end
    end

    context 'schemes not in spec' do
      let(:activedocs) { YAML.safe_load(basic_swagger_content) }

      it 'schemes set' do
        subject.set_server_url(activedocs, url)
        expect(activedocs['schemes']).to match_array([url_obj.scheme])
      end
    end

    context 'schemes in spec' do
      let(:activedocs) { YAML.safe_load(schemes_swagger_content) }

      it 'schemes overrided' do
        subject.set_server_url(activedocs, url)
        expect(activedocs['schemes']).to match_array([url_obj.scheme])
      end
    end

    context 'basePath not in spec' do
      let(:activedocs) { YAML.safe_load(basic_swagger_content) }

      it 'basePath set' do
        subject.set_server_url(activedocs, url)
        expect(activedocs['basePath']).to eq(url_obj.path)
      end
    end

    context 'basePath in spec' do
      let(:activedocs) { YAML.safe_load(base_path_swagger_content) }

      it 'basePath overrided' do
        subject.set_server_url(activedocs, url)
        expect(activedocs['basePath']).to eq(url_obj.path)
      end
    end
  end

  context '#set_oauth2_urls' do
    let(:authorization_url) { 'https://sso.new_host.com:443/auth' }
    let(:token_url) { 'https://sso.new_host.com:443/token' }

    context 'implicit oauth' do
      let(:activedocs) { YAML.safe_load(oauth2_implicit_swagger_content) }

      it 'authorization set' do
        subject.set_oauth2_urls(activedocs, 'petstore_oauth', authorization_url, token_url)
        expect(activedocs.dig('securityDefinitions', 'petstore_oauth', 'authorizationUrl')).to eq(authorization_url)
      end
    end

    context 'password auth' do
      let(:activedocs) { YAML.safe_load(oauth2_password_swagger_content) }

      it 'token_url set' do
        subject.set_oauth2_urls(activedocs, 'petstore_oauth', authorization_url, token_url)
        expect(activedocs.dig('securityDefinitions', 'petstore_oauth', 'tokenUrl')).to eq(token_url)
      end
    end

    context 'application auth' do
      let(:activedocs) { YAML.safe_load(oauth2_application_swagger_content) }

      it 'token_url set' do
        subject.set_oauth2_urls(activedocs, 'petstore_oauth', authorization_url, token_url)
        expect(activedocs.dig('securityDefinitions', 'petstore_oauth', 'tokenUrl')).to eq(token_url)
      end
    end

    context 'accessCode auth' do
      let(:activedocs) { YAML.safe_load(oauth2_accessCode_swagger_content) }

      it 'token_url set' do
        subject.set_oauth2_urls(activedocs, 'petstore_oauth', authorization_url, token_url)
        expect(activedocs.dig('securityDefinitions', 'petstore_oauth', 'tokenUrl')).to eq(token_url)
      end

      it 'authorization set' do
        subject.set_oauth2_urls(activedocs, 'petstore_oauth', authorization_url, token_url)
        expect(activedocs.dig('securityDefinitions', 'petstore_oauth', 'authorizationUrl')).to eq(authorization_url)
      end
    end
  end
end
