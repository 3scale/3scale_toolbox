RSpec.describe 'OpenAPI import basepath diff' do
  include_context :oas_common_context

  let(:oas_resource_path) { File.join(resources_path, 'petstore.yaml') }

  let(:command_line_str) do
    "import openapi -t #{system_name} -d #{destination_url}" \
    ' --override-private-basepath=/private' \
    ' --override-public-basepath=/public' \
    " #{oas_resource_path}"
  end

  let(:backend_version) { '1' }
  let(:path) { '/public/pet/findByStatus' }
  let(:sandbox_host) { service_proxy.fetch('sandbox_endpoint') }
  let(:account_name) { "account_#{random_lowercase_name}" }
  let(:account) { api3scale_client.signup(name: account_name, username: account_name) }
  let(:application_plan) do
    ThreeScaleToolbox::Entities::ApplicationPlan.create(service: service, plan_attrs: {'name' => "appplan_#{random_lowercase_name}"})
  end
  let(:application) do
    api3scale_client.create_application(account['id'], plan_id: application_plan.id, user_key: random_lowercase_name)
  end
  let(:api_key) { application['user_key'] }

  let(:response) do
    uri = URI("#{sandbox_host}#{path}")
    uri.query = URI.encode_www_form(api_key: api_key)
    resp = nil
    5.times do |i|
      resp = Net::HTTP.get_response(uri)
      break if resp.is_a?(Net::HTTPOK)

      sleep 5
      warn "basepath_spec: attempt #{i + 1} got #{resp.class}, retrying..."
    end
    resp
  end

  after :example do
    api3scale_client.delete_application(account['id'], application['id'])
    api3scale_client.delete_account(account['id'])
  end

  it 'request url is rewritten' do
    expect(subject).to eq(0)
    expect(response.class).to be(Net::HTTPOK)
    expect(JSON.parse(response.body)).to include('path' => '/private/pet/findByStatus')
  end
end
