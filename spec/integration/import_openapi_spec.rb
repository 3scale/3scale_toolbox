require '3scale_toolbox'

RSpec.shared_context :import_oas_stubbed_api3scale_client do
  let(:internal_http_client) { double('internal_http_client') }
  let(:http_client_class) { class_double('ThreeScale::API::HttpClient').as_stubbed_const }

  let(:endpoint) { 'https://example.com' }
  let(:provider_key) { '123456789' }
  let(:verify_ssl) { true }
  let(:external_http_client) { double('external_http_client') }
  let(:api3scale_client) { ThreeScale::API::Client.new(external_http_client) }
  let(:fake_service_id) { '100' }

  let(:service_attr) { { 'service' => { 'id' => fake_service_id } } }
  let(:metrics) do
    {
      'metrics' => [
        { 'metric' => { 'id' => '1', 'system_name' => 'hits' } }
      ]
    }
  end
  let(:external_methods) do
    {
      'methods' => [
        { 'method' => { 'id' => '1', 'friendly_name' => 'addPet', 'system_name' => 'addpet' } },
        { 'method' => { 'id' => '2', 'friendly_name' => 'updatePet', 'system_name' => 'updatepet' } },
        { 'method' => { 'id' => '3', 'friendly_name' => 'findPetsByStatus', 'system_name' => 'findpetsbystatus' } }
      ]
    }
  end
  let(:external_mapping_rules) do
    {
      'mapping_rules' => [
        { 'mapping_rule' => { 'delta' => 1, 'http_method' => 'POST', 'pattern' => '/v2/pet' } },
        { 'mapping_rule' => { 'delta' => 1, 'http_method' => 'PUT', 'pattern' => '/v2/pet' } },
        { 'mapping_rule' => { 'delta' => 1, 'http_method' => 'GET', 'pattern' => '/v2/pet/findByStatus' } }
      ]
    }
  end
  let(:existing_mapping_rules) do
    {
      'mapping_rules' => [
        { 'mapping_rule' => { 'id' => '1', 'delta' => 1, 'http_method' => 'GET', 'pattern' => '/' } }
      ]
    }
  end
  let(:existing_services) do
    {
      'services' => [
        { 'service' => { 'id' => fake_service_id, 'system_name' => system_name } }
      ]
    }
  end

  before :example do
    puts '============ RUNNING STUBBED 3SCALE API CLIENT =========='
    ##
    # Internal http client stub
    allow(internal_http_client).to receive(:post).with('/admin/api/services', anything)
                                                 .and_return(service_attr)
    expect(http_client_class).to receive(:new).and_return(internal_http_client)
    expect(internal_http_client).to receive(:get).with('/admin/api/services/100/metrics')
                                                 .and_return(metrics)
    expect(internal_http_client).to receive(:post).with('/admin/api/services/100/metrics/1/methods', anything)
                                                  .exactly(3).times
                                                  .and_return('id' => '1')
    expect(internal_http_client).to receive(:get).with('/admin/api/services/100/proxy/mapping_rules').and_return(existing_mapping_rules)
    expect(internal_http_client).to receive(:delete).with('/admin/api/services/100/proxy/mapping_rules/1')
    expect(internal_http_client).to receive(:post).with('/admin/api/services/100/proxy/mapping_rules', anything)
                                                  .exactly(3).times

    ##
    # External http client stub
    allow(external_http_client).to receive(:post).with('/admin/api/services', anything)
                                                 .and_return(service_attr)
    expect(external_http_client).to receive(:get).with('/admin/api/services')
                                                 .and_return(existing_services)
    allow(external_http_client).to receive(:get).with('/admin/api/services/100/metrics')
                                                .and_return(metrics)
    allow(external_http_client).to receive(:get).with('/admin/api/services/100/metrics/1/methods')
                                                .and_return(external_methods)
    allow(external_http_client).to receive(:get).with('/admin/api/services/100/proxy/mapping_rules')
                                                .and_return(external_mapping_rules)
  end
end

RSpec.shared_examples 'oas imported' do
  let(:expected_methods) do
    [
      { 'friendly_name' => 'addPet', 'system_name' => 'addpet' },
      { 'friendly_name' => 'updatePet', 'system_name' => 'updatepet' },
      { 'friendly_name' => 'findPetsByStatus', 'system_name' => 'findpetsbystatus' }
    ]
  end
  let(:method_keys) { %w[friendly_name system_name] }
  let(:expected_mapping_rules) do
    [
      { 'pattern' => '/v2/pet', 'http_method' => 'POST', 'delta' => 1 },
      { 'pattern' => '/v2/pet', 'http_method' => 'PUT', 'delta' => 1 },
      { 'pattern' => '/v2/pet/findByStatus', 'http_method' => 'GET', 'delta' => 1 }
    ]
  end
  let(:mapping_rule_keys) { %w[pattern http_method delta] }

  it 'methods are created' do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)
    expect(expected_methods.size).to be > 0
    # test Set(service.methods) includes Set(expected_methods)
    # with a custom identity method for methods
    expect(
      ThreeScaleToolbox::Helper.array_difference(expected_methods, service.methods) do |el1, el2|
        ThreeScaleToolbox::Helper.compare_hashes(el1, el2, method_keys)
      end
    ).to be_empty
  end

  it 'mapping rules are created' do
    expect { subject }.to output.to_stdout
    expect(subject).to eq(0)
    expect(expected_mapping_rules.size).to be > 0
    # expect Set(service.mapping_rules) == Set(expected_mapping_rules)
    # with a custom identity method for mapping_rules
    expect(
      ThreeScaleToolbox::Helper.array_difference(expected_mapping_rules, service.mapping_rules) do |el1, el2|
        ThreeScaleToolbox::Helper.compare_hashes(el1, el2, mapping_rule_keys)
      end
    ).to be_empty
    expect(
      ThreeScaleToolbox::Helper.array_difference(service.mapping_rules, expected_mapping_rules) do |el1, el2|
        ThreeScaleToolbox::Helper.compare_hashes(el1, el2, mapping_rule_keys)
      end
    ).to be_empty
  end
end

RSpec.shared_context :import_oas_real_cleanup do
  after :example do
    service.delete_service
  end
end

RSpec.describe 'e2e OpenAPI import' do
  include_context :resources
  include_context :random_name
  if ENV.key?('ENDPOINT')
    include_context :real_api3scale_client
    include_context :import_oas_real_cleanup
  else
    include_context :import_oas_stubbed_api3scale_client
  end

  # render from template to avoid system_name collision
  let(:system_name) { "test_openapi_#{random_lowercase_name}" }
  let(:destination_url) do
    endpoint_uri = URI(endpoint)
    endpoint_uri.user = provider_key
    endpoint_uri.to_s
  end
  let(:oas_resource_path) { File.join(resources_path, 'petstore.yaml') }
  let(:command_line_str) { "import openapi -t #{system_name} -d #{destination_url} #{oas_resource_path}" }
  subject { ThreeScaleToolbox::CLI.run(command_line_str.split) }
  let(:service_id) do
    # figure out service by system_name
    api3scale_client.list_services.find { |service| service['system_name'] == system_name }['id']
  end
  let(:service) do
    ThreeScaleToolbox::Entities::Service.new(id: service_id, remote: api3scale_client)
  end

  context 'when target service exists' do
    before :example do
      ThreeScaleToolbox::Entities::Service.create(
        remote: api3scale_client, service: { 'name' => system_name }, system_name: system_name
      )
    end

    it_behaves_like 'oas imported'
  end

  context 'when target service does not exist' do
    it_behaves_like 'oas imported'
  end
end
