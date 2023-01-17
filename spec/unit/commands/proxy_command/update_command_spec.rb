RSpec.describe ThreeScaleToolbox::Commands::ProxyCommand::UpdateSubcommand do
  context '#run' do
    let(:remote) { instance_double(ThreeScale::API::Client) }
    let(:remote_name) { 'myremote' }
    let(:service_ref) { 'myservice' }
    let(:service_id) { 1 }
    let(:arguments) { {remote: remote_name, service_ref: service_ref} }
    let(:options) { { param: ['a' => 1, 'b' => 2] } }
    let(:proxy_attrs) { { 'id' => '1' } }
    let(:pretty_printed_proxy) { JSON.pretty_generate(proxy_attrs) + "\n" }
    let(:service_class) { class_double(ThreeScaleToolbox::Entities::Service).as_stubbed_const }
    let(:service) { instance_double(ThreeScaleToolbox::Entities::Service) }

    subject { described_class.new(options, arguments, nil) }

    before :example do
      allow(subject).to receive(:threescale_client).with(remote_name).and_return(remote)
      allow(service_class).to receive(:find).with(remote: remote, ref: service_ref).and_return(service)
    end

    it 'APIcast configuration updated' do
      expect(service).to receive(:update_proxy).with({'a' => 1, 'b' => 2}).and_return(proxy_attrs)
      expect { subject.run }.to output(pretty_printed_proxy).to_stdout
    end

    context 'when no params' do
      let(:options) { {} }

      it 'error raised' do
        expect { subject.run }.to raise_error(ThreeScaleToolbox::Error, /APIcast configuration parameters required/)
      end
    end
  end

  context 'ProxyParamTransformer class' do
    subject { described_class::ProxyParamTransformer.new }

    it 'raise error when param is "="' do
      expect { subject.call('=') }.to raise_error(ArgumentError)
    end

    it 'raise error when param does not have "="' do
      expect { subject.call('something') }.to raise_error(ArgumentError)
    end

    it 'raise error when param is "key="' do
      expect { subject.call('key=') }.to raise_error(ArgumentError)
    end

    it 'raise error when param is "=value"' do
      expect { subject.call('=value') }.to raise_error(ArgumentError)
    end

    it 'parse key=value' do
      expect(subject.call('key=value')).to eq('key' => 'value')
    end
  end
end
