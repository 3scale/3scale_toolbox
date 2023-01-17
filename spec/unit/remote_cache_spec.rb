RSpec.describe ThreeScaleToolbox::RemoteCache do
  let(:proxied_object) { double }
  let(:service_id) { 1 }
  let(:backend_id) { 7654 }
  let(:metrics) { [{'id' =>  1}, {'id' =>  2}] }
  let(:methods) { [{'id' =>  2}] }
  let(:backends_1) { [{'id' =>  '1'}, {'id' =>  '2'}] }
  let(:backends_2) { [{'id' =>  '3'}, {'id' =>  '4'}] }
  let(:backends_3) { [{'id' =>  '1000'}] }
  let(:error_response) { {'errors' => {}} }
  subject { described_class.new(proxied_object) }

  it 'list_metrics first call cache miss' do
    expect(proxied_object).to receive(:list_metrics).and_return(metrics)
    expect(subject.list_metrics(service_id)).to eq(metrics)
  end

  it 'list_metrics second call cache hit' do
    expect(proxied_object).to receive(:list_metrics).and_return(metrics)
    expect(subject.list_metrics(service_id)).to eq(metrics)
    expect(subject.list_metrics(service_id)).to eq(metrics)
  end

  it 'list_metrics different service_id cache miss' do
    expect(proxied_object).to receive(:list_metrics).with(service_id).and_return(metrics)
    expect(proxied_object).to receive(:list_metrics).with(service_id+1).and_return([])
    expect(subject.list_metrics(service_id)).to eq(metrics)
    expect(subject.list_metrics(service_id+1)).to eq([])
  end

  context 'list_metrics returns error' do
    it 'cache miss' do
      expect(proxied_object).to receive(:list_metrics).twice.and_return(error_response)
      expect(subject.list_metrics(service_id)).to eq(error_response)
      expect(subject.list_metrics(service_id)).to eq(error_response)
    end
  end

  context 'list_metrics then create_metric called' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:create_metric)
      subject.list_metrics(service_id)
      subject.create_metric(service_id, {})
    end

    it 'cache miss' do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end

  context 'list_metrics then create_metric returns error' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:create_metric).and_return(error_response)
      subject.list_metrics(service_id)
      subject.create_metric(service_id, {})
    end

    it 'cache hit' do
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end

  context 'list_metrics then update_metric called' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:update_metric)
      subject.list_metrics(service_id)
      subject.update_metric(service_id, 1, {})
    end

    it 'cache miss' do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end

  context 'list_metrics then update_metric returns error' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:update_metric).and_return(error_response)
      subject.list_metrics(service_id)
      subject.update_metric(service_id, 1, {})
    end

    it 'cache hit' do
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end

  context 'list_metrics then delete_metric called' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:delete_metric)
      subject.list_metrics(service_id)
      subject.delete_metric(service_id, 1)
    end

    it 'cache miss' do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end

  it 'list_methods first call cache miss' do
    expect(proxied_object).to receive(:list_methods).and_return(methods)
    expect(subject.list_methods(service_id, 1)).to eq(methods)
  end

  it 'list_methods second call cache hit' do
    expect(proxied_object).to receive(:list_methods).and_return(methods)
    expect(subject.list_methods(service_id, 1)).to eq(methods)
    expect(subject.list_methods(service_id, 1)).to eq(methods)
  end

  it 'list_methods different service_id cache miss' do
    expect(proxied_object).to receive(:list_methods).with(service_id, 1).and_return(methods)
    expect(proxied_object).to receive(:list_methods).with(service_id+1, 1).and_return([])
    expect(subject.list_methods(service_id, 1)).to eq(methods)
    expect(subject.list_methods(service_id+1, 1)).to eq([])
  end

  context 'list_methods returns error' do
    it 'cache miss' do
      expect(proxied_object).to receive(:list_methods).twice.and_return(error_response)
      expect(subject.list_methods(service_id, 1)).to eq(error_response)
      expect(subject.list_methods(service_id, 1)).to eq(error_response)
    end
  end

  context 'list_methods then create_method called' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:list_methods).and_return(methods)
      expect(proxied_object).to receive(:create_method)
      subject.list_metrics(service_id)
      subject.list_methods(service_id, 1)
      subject.create_method(service_id, 1, {})
    end

    it 'methods cache miss' do
      expect(proxied_object).to receive(:list_methods).and_return(methods)
      expect(subject.list_methods(service_id, 1)).to eq(methods)
    end

    it 'metrics cache miss' do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end

  context 'list_methods then create_method returns error' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:list_methods).and_return(methods)
      expect(proxied_object).to receive(:create_method).and_return(error_response)

      subject.list_metrics(service_id)
      subject.list_methods(service_id, 1)
      subject.create_method(service_id, 1, {})
    end

    it 'methods cache hit' do
      expect(subject.list_methods(service_id, 1)).to eq(methods)
    end

    it 'metrics cache hit' do
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end

  context 'list_methods then update_method called' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:list_methods).and_return(methods)
      expect(proxied_object).to receive(:update_method)
      subject.list_metrics(service_id)
      subject.list_methods(service_id, 1)
      subject.update_method(service_id, 1, 10, {})
    end

    it 'methods cache miss' do
      expect(proxied_object).to receive(:list_methods).and_return(methods)
      expect(subject.list_methods(service_id, 1)).to eq(methods)
    end

    it 'metrics cache miss' do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end

  context 'list_methods then update_method returns error' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:list_methods).and_return(methods)
      expect(proxied_object).to receive(:update_method).and_return(error_response)

      subject.list_metrics(service_id)
      subject.list_methods(service_id, 1)
      subject.update_method(service_id, 1, 10, {})
    end

    it 'methods cache hit' do
      expect(subject.list_methods(service_id, 1)).to eq(methods)
    end

    it 'metrics cache hit' do
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end

  context 'list_methods then delete_method called' do
    before :example do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(proxied_object).to receive(:list_methods).and_return(methods)
      expect(proxied_object).to receive(:delete_method)
      subject.list_metrics(service_id)
      subject.list_methods(service_id, 1)
      subject.delete_method(service_id, 1, 10)
    end

    it 'methods cache miss' do
      expect(proxied_object).to receive(:list_methods).and_return(methods)
      expect(subject.list_methods(service_id, 1)).to eq(methods)
    end

    it 'metrics cache miss' do
      expect(proxied_object).to receive(:list_metrics).and_return(metrics)
      expect(subject.list_metrics(service_id)).to eq(metrics)
    end
  end

  ###
  # Backends
  ###

  it 'list_backend_metrics first call cache miss' do
    expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
    expect(subject.list_backend_metrics(backend_id)).to eq(metrics)
  end

  it 'list_backend_metrics second call cache hit' do
    expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
    expect(subject.list_backend_metrics(backend_id)).to eq(metrics)
    expect(subject.list_backend_metrics(backend_id)).to eq(metrics)
  end

  it 'list_backend_metrics different backend_id cache miss' do
    expect(proxied_object).to receive(:list_backend_metrics).with(backend_id).and_return(metrics)
    expect(proxied_object).to receive(:list_backend_metrics).with(backend_id + 1).and_return([])
    expect(subject.list_backend_metrics(backend_id)).to eq(metrics)
    expect(subject.list_backend_metrics(backend_id + 1)).to eq([])
  end

  context 'list_backend_metrics returns error' do
    it 'cache miss' do
      expect(proxied_object).to receive(:list_backend_metrics).twice.and_return(error_response)
      expect(subject.list_backend_metrics(backend_id)).to eq(error_response)
      expect(subject.list_backend_metrics(backend_id)).to eq(error_response)
    end
  end

  context 'list_backend_metrics then create_backend_metric called' do
    before :example do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(proxied_object).to receive(:create_backend_metric)
      subject.list_backend_metrics(backend_id)
      subject.create_backend_metric(backend_id, {})
    end

    it 'cache miss' do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(subject.list_backend_metrics(backend_id)).to eq(metrics)
    end
  end

  context 'list_backend_metrics then create_backend_metric returns error' do
    before :example do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(proxied_object).to receive(:create_backend_metric).and_return(error_response)
      subject.list_backend_metrics(backend_id)
      subject.create_backend_metric(backend_id, {})
    end

    it 'cache hit' do
      expect(subject.list_backend_metrics(backend_id)).to eq(metrics)
    end
  end

  context 'list_backend_metrics then update_backend_metric called' do
    before :example do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(proxied_object).to receive(:update_backend_metric)
      subject.list_backend_metrics(backend_id)
      subject.update_backend_metric(backend_id, 1, {})
    end

    it 'cache miss' do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(subject.list_backend_metrics(backend_id)).to eq(metrics)
    end
  end

  context 'list_backend_metrics then update_backend_metric returns error' do
    before :example do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(proxied_object).to receive(:update_backend_metric).and_return(error_response)
      subject.list_backend_metrics(backend_id)
      subject.update_backend_metric(backend_id, 1, {})
    end

    it 'cache hit' do
      expect(subject.list_backend_metrics(backend_id)).to eq(metrics)
    end
  end

  context 'list_backend_metrics then delete_backend_metric called' do
    before :example do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(proxied_object).to receive(:delete_backend_metric)
      subject.list_backend_metrics(backend_id)
      subject.delete_backend_metric(backend_id, 1)
    end

    it 'cache miss' do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(subject.list_backend_metrics(backend_id)).to eq(metrics)
    end
  end

  it 'list_backend_methods first call cache miss' do
    expect(proxied_object).to receive(:list_backend_methods).and_return(methods)
    expect(subject.list_backend_methods(backend_id, 1)).to eq(methods)
  end

  it 'list_backend_methods second call cache hit' do
    expect(proxied_object).to receive(:list_backend_methods).and_return(methods)
    expect(subject.list_backend_methods(backend_id, 1)).to eq(methods)
    expect(subject.list_backend_methods(backend_id, 1)).to eq(methods)
  end

  it 'list_backend_methods different backend_id cache miss' do
    expect(proxied_object).to receive(:list_backend_methods).with(backend_id, 1).and_return(methods)
    expect(proxied_object).to receive(:list_backend_methods).with(backend_id+1, 1).and_return([])
    expect(subject.list_backend_methods(backend_id, 1)).to eq(methods)
    expect(subject.list_backend_methods(backend_id+1, 1)).to eq([])
  end

  context 'list_backend_methods returns error' do
    it 'cache miss' do
      expect(proxied_object).to receive(:list_backend_methods).twice.and_return(error_response)
      expect(subject.list_backend_methods(backend_id, 1)).to eq(error_response)
      expect(subject.list_backend_methods(backend_id, 1)).to eq(error_response)
    end
  end

  context 'list_backend_methods then create_backend_method called' do
    before :example do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(proxied_object).to receive(:list_backend_methods).and_return(methods)
      expect(proxied_object).to receive(:create_backend_method)
      subject.list_backend_metrics(backend_id)
      subject.list_backend_methods(backend_id, 1)
      subject.create_backend_method(backend_id, 1, {})
    end

    it 'methods cache miss' do
      expect(proxied_object).to receive(:list_backend_methods).and_return(methods)
      expect(subject.list_backend_methods(backend_id, 1)).to eq(methods)
    end

    it 'metrics cache miss' do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(subject.list_backend_metrics(backend_id)).to eq(metrics)
    end
  end

  context 'list_backend_methods then create_backend_method returns error' do
    before :example do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(proxied_object).to receive(:list_backend_methods).and_return(methods)
      expect(proxied_object).to receive(:create_backend_method).and_return(error_response)
      subject.list_backend_metrics(backend_id)
      subject.list_backend_methods(backend_id, 1)
      subject.create_backend_method(backend_id, 1, {})
    end

    it 'methods cache hit' do
      expect(subject.list_backend_methods(backend_id, 1)).to eq(methods)
    end

    it 'metrics cache hit' do
      expect(subject.list_backend_metrics(backend_id)).to eq(metrics)
    end
  end

  context 'list_backend_methods then update_backend_method called' do
    before :example do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(proxied_object).to receive(:list_backend_methods).and_return(methods)
      expect(proxied_object).to receive(:update_backend_method)
      subject.list_backend_metrics(backend_id)
      subject.list_backend_methods(backend_id, 1)
      subject.update_backend_method(backend_id, 1, 10, {})
    end

    it 'methods cache miss' do
      expect(proxied_object).to receive(:list_backend_methods).and_return(methods)
      expect(subject.list_backend_methods(backend_id, 1)).to eq(methods)
    end

    it 'metrics cache miss' do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(subject.list_backend_metrics(backend_id)).to eq(metrics)
    end
  end

  context 'list_backend_methods then update_backend_method returns error' do
    before :example do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(proxied_object).to receive(:list_backend_methods).and_return(methods)
      expect(proxied_object).to receive(:update_backend_method).and_return(error_response)
      subject.list_backend_metrics(backend_id)
      subject.list_backend_methods(backend_id, 1)
      subject.update_backend_method(backend_id, 1, 10, {})
    end

    it 'methods cache hit' do
      expect(subject.list_backend_methods(backend_id, 1)).to eq(methods)
    end

    it 'metrics cache hit' do
      expect(subject.list_backend_metrics(backend_id)).to eq(metrics)
    end
  end

  context 'list_backend_methods then delete_backend_method called' do
    before :example do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(proxied_object).to receive(:list_backend_methods).and_return(methods)
      expect(proxied_object).to receive(:delete_backend_method)
      subject.list_backend_metrics(backend_id)
      subject.list_backend_methods(backend_id, 1)
      subject.delete_backend_method(backend_id, 1, 10)
    end

    it 'methods cache miss' do
      expect(proxied_object).to receive(:list_backend_methods).and_return(methods)
      expect(subject.list_backend_methods(backend_id, 1)).to eq(methods)
    end

    it 'metrics cache miss' do
      expect(proxied_object).to receive(:list_backend_metrics).and_return(metrics)
      expect(subject.list_backend_metrics(backend_id)).to eq(metrics)
    end
  end

  context '#backend' do
    let(:backends_1) { [{'id' =>  '1'}, {'id' =>  '2'}] }
    let(:backends_2) { [{'id' =>  '3'}, {'id' =>  '4'}] }

    before :example do
      expect(proxied_object).to receive(:list_backends).with(hash_including(page: 1)).and_return(backends_1)
      expect(proxied_object).to receive(:list_backends).with(hash_including(page: 2)).and_return(backends_2)
      subject.list_backends(page: 1, per_page: 2)
      subject.list_backends(page: 2, per_page: 2)
    end

    it 'backends cache hit' do
      expect(proxied_object).not_to receive(:backend)
      expect(subject.backend('1')).to include('id' => '1')
    end

    it 'backends cache miss' do
      expect(proxied_object).to receive(:backend).exactly(3).with('1000').and_return('id' => '1000')
      # miss
      expect(subject.backend('1000')).to include('id' => '1000')
      # backend(id) does not populate cache
      # miss
      expect(subject.backend('1000')).to include('id' => '1000')
      # miss
      expect(subject.backend('1000')).to include('id' => '1000')
    end

    it 'on error returns the error' do
      expect(proxied_object).to receive(:backend).with('1000').and_return(error_response)
      expect(subject.backend('1000')).to eq(error_response)
    end
  end

  context '#list_backends' do
    before :example do
      expect(proxied_object).to receive(:list_backends).with(hash_including(page: 1)).and_return(backends_1)
      expect(proxied_object).to receive(:list_backends).with(hash_including(page: 2)).and_return(backends_2)
      subject.list_backends(page: 1, per_page: 2)
      subject.list_backends(page: 2, per_page: 2)
    end

    it 'backends cache hit' do
      expect(proxied_object).not_to receive(:list_backends)
      expect(subject.list_backends(page: 1, per_page: 2)).to eq(backends_1)
    end

    it 'backends cache miss' do
      expect(proxied_object).to receive(:list_backends).with({page: 3, per_page: 2}).and_return(backends_3)
      # miss
      expect(subject.list_backends(page: 3, per_page: 2)).to eq(backends_3)
      # hit
      expect(subject.list_backends(page: 3, per_page: 2)).to eq(backends_3)
      # hit
      expect(subject.list_backends(page: 3, per_page: 2)).to eq(backends_3)
    end

    it 'on error returns the error' do
      expect(proxied_object).to receive(:list_backends).with({page: 3, per_page: 2}).and_return(error_response)
      expect(subject.list_backends(page: 3, per_page: 2)).to eq(error_response)
    end
  end

  context '#create_backend' do
    let(:create_attrs) { { 'a' => 1 } }

    it 'proxied object called' do
      expect(proxied_object).to receive(:create_backend).with(create_attrs).and_return({'id' => 1})
      expect(subject.create_backend(create_attrs)).to eq({'id' => 1})
    end

    it 'clears cache' do
      expect(proxied_object).to receive(:create_backend).with(create_attrs).and_return({'id' => 1})
      expect(proxied_object).to receive(:list_backends).twice.with(hash_including(page: 1)).and_return(backends_1)
      # cache warming up
      # miss
      subject.list_backends(page: 1, per_page: 2)
      # hit
      subject.list_backends(page: 1, per_page: 2)
      subject.create_backend(create_attrs)
      # miss
      subject.list_backends(page: 1, per_page: 2)
    end

    it 'cache not cleared on error' do
      expect(proxied_object).to receive(:create_backend).with(create_attrs).and_return(error_response)
      expect(proxied_object).to receive(:list_backends).once.with(hash_including(page: 1)).and_return(backends_1)
      # cache warming up
      # miss
      subject.list_backends(page: 1, per_page: 2)
      subject.create_backend(create_attrs)
      # hit
      subject.list_backends(page: 1, per_page: 2)
    end
  end

  context '#update_backend' do
    let(:update_attrs) { { 'a' => 1 } }

    it 'proxied object called' do
      expect(proxied_object).to receive(:update_backend).with(backend_id, update_attrs).and_return({'id' => backend_id})
      expect(subject.update_backend(backend_id, update_attrs)).to eq({'id' => backend_id})
    end

    it 'clears cache' do
      expect(proxied_object).to receive(:update_backend).with(backend_id, update_attrs).and_return({'id' => backend_id})
      expect(proxied_object).to receive(:list_backends).twice.with(hash_including(page: 1)).and_return(backends_1)
      # cache warming up
      # miss
      subject.list_backends(page: 1, per_page: 2)
      # hit
      subject.list_backends(page: 1, per_page: 2)
      subject.update_backend(backend_id, update_attrs)
      # miss
      subject.list_backends(page: 1, per_page: 2)
    end

    it 'cache not cleared on error' do
      expect(proxied_object).to receive(:update_backend).with(backend_id, update_attrs).and_return(error_response)
      expect(proxied_object).to receive(:list_backends).once.with(hash_including(page: 1)).and_return(backends_1)
      # cache warming up
      # miss
      subject.list_backends(page: 1, per_page: 2)
      subject.update_backend(backend_id, update_attrs)
      # hit
      subject.list_backends(page: 1, per_page: 2)
    end
  end

  context '#delete_backend' do
    it 'proxied object called' do
      expect(proxied_object).to receive(:delete_backend).with(backend_id).and_return({})
      expect(subject.delete_backend(backend_id)).to be_truthy
    end

    it 'clears cache' do
      expect(proxied_object).to receive(:delete_backend).with(backend_id).and_return({})
      expect(proxied_object).to receive(:list_backends).twice.with(hash_including(page: 1)).and_return(backends_1)
      # cache warming up
      # miss
      subject.list_backends(page: 1, per_page: 2)
      # hit
      subject.list_backends(page: 1, per_page: 2)
      subject.delete_backend(backend_id)
      # miss
      subject.list_backends(page: 1, per_page: 2)
    end

    it 'cache not cleared on error' do
      expect(proxied_object).to receive(:delete_backend).with(backend_id).and_return(error_response)
      expect(proxied_object).to receive(:list_backends).once.with(hash_including(page: 1)).and_return(backends_1)
      # cache warming up
      # miss
      subject.list_backends(page: 1, per_page: 2)
      subject.delete_backend(backend_id)
      # hit
      subject.list_backends(page: 1, per_page: 2)
    end
  end
end
