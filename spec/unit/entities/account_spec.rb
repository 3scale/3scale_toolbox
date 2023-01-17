RSpec.describe ThreeScaleToolbox::Entities::Account do
  let(:account_ref) { 1000 }
  let(:remote) { instance_double(ThreeScale::API::Client, 'remote') }
  let(:account) { instance_double(ThreeScaleToolbox::Entities::Account) }
  let(:show_account_error) { { 'errors' => 'some error' } }
  let(:application_class) { class_double(ThreeScaleToolbox::Entities::Application).as_stubbed_const }

  context '#Account.find' do
    context 'show_account returns error' do
      before :example do
        expect(remote).to receive(:show_account).with(account_ref).and_return(show_account_error)
      end

      it 'error is raised' do
        expect do
          described_class.find(remote: remote, ref: account_ref)
        end.to raise_error(ThreeScaleToolbox::ThreeScaleApiError, /Account attrs not read/)
      end
    end

    context 'show_account raises NotFoundError' do
      before :example do
        expect(remote).to receive(:show_account).with(account_ref)
                                                .and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
      end

      it 'find_by_example is called' do
        expect(described_class).to receive(:find_by_text).with(account_ref, remote)
                                                         .and_return(account)
        expect(described_class.find(remote: remote, ref: account_ref)).to be(account)
      end
    end

    context 'show_account returns account' do
      let(:account_attrs) { { 'id' => account_ref, 'name' => 'some name' } }
      before :example do
        expect(remote).to receive(:show_account).with(account_ref).and_return(account_attrs)
      end

      it 'account instance is returned' do
        result = described_class.find(remote: remote, ref: account_ref)
        expect(result).not_to be_nil
        expect(result.attrs).to eq(account_attrs)
      end
    end
  end

  context '#Account.find_by_text' do
    let(:text) { 'sometext' }
    let(:account_attrs) { { 'id' => account_ref, 'name' => 'some name' } }

    context 'remote returns error' do
      before :example do
        expect(remote).to receive(:find_account).and_return('errors' => 'some error')
      end

      it 'raises error' do
        expect do
          described_class.find_by_text(text, remote)
        end.to raise_error(ThreeScaleToolbox::ThreeScaleApiError, /Account find returned errors/)
      end
    end

    context 'account found by email' do
      before :example do
        expect(remote).to receive(:find_account).with({email: text}).and_return(account_attrs)
      end

      it 'instance returned' do
        account = described_class.find_by_text(text, remote)
        expect(account).not_to be_nil
        expect(account.id).to eq(account_ref)
      end
    end

    context 'account found by username' do
      before :example do
        expect(remote).to receive(:find_account).with({email: text})
                                                .and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
        expect(remote).to receive(:find_account).with({username: text}).and_return(account_attrs)
      end

      it 'instance returned' do
        account = described_class.find_by_text(text, remote)
        expect(account).not_to be_nil
        expect(account.id).to eq(account_ref)
      end
    end

    context 'account found by user_id' do
      before :example do
        expect(remote).to receive(:find_account).with({email: text})
                                                .and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
        expect(remote).to receive(:find_account).with({username: text})
                                                .and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
        expect(remote).to receive(:find_account).with({user_id: text}).and_return(account_attrs)
      end

      it 'instance returned' do
        account = described_class.find_by_text(text, remote)
        expect(account).not_to be_nil
        expect(account.id).to eq(account_ref)
      end
    end

    context 'account found by provider key' do
      before :example do
        expect(remote).to receive(:find_account).with({email: text})
                                                .and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
        expect(remote).to receive(:find_account).with({username: text})
                                                .and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
        expect(remote).to receive(:find_account).with({user_id: text})
                                                .and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
        expect(remote).to receive(:find_account).with({buyer_provider_key: text,
                                                      buyer_service_token: text})
                                                .and_return(account_attrs)
      end

      it 'instance returned' do
        account = described_class.find_by_text(text, remote)
        expect(account).not_to be_nil
        expect(account.id).to eq(account_ref)
      end
    end

    context 'account not found' do
      before :example do
        expect(remote).to receive(:find_account).with({email: text})
                                                .and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
        expect(remote).to receive(:find_account).with({username: text})
                                                .and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
        expect(remote).to receive(:find_account).with({user_id: text})
                                                .and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
        expect(remote).to receive(:find_account).with({buyer_provider_key: text,
                                                      buyer_service_token: text})
                                                .and_raise(ThreeScale::API::HttpClient::NotFoundError.new(nil))
      end

      it 'nil returned' do
        account = described_class.find_by_text(text, remote)
        expect(account).to be_nil
      end
    end
  end

  context '#applications' do
    let(:subject) { described_class.new(id: account_ref, remote: remote) }

    context 'list_account_applications returns error' do
      let(:request_error) { { 'errors' => 'some error' } }

      before :example do
        expect(remote).to receive(:list_account_applications).with(account_ref)
                                                             .and_return(request_error)
      end

      it 'error is raised' do
        expect { subject.applications }.to raise_error(ThreeScaleToolbox::ThreeScaleApiError, /Account applications not read/)
      end
    end

    context 'list_account_applications returns applications' do
      let(:app01_attrs) { { 'id' => 1, 'name' => 'app01' } }
      let(:app02_attrs) { { 'id' => 2, 'name' => 'app02' } }
      let(:app03_attrs) { { 'id' => 3, 'name' => 'app03' } }
      let(:applications) { [app01_attrs, app02_attrs, app03_attrs] }

      before :example do
        expect(remote).to receive(:list_account_applications).with(account_ref)
                                                             .and_return(applications)
      end

      it 'app01 is returned' do
        apps = subject.applications
        expect(apps.map(&:id)).to include(1)
      end

      it 'app02 is returned' do
        apps = subject.applications
        expect(apps.map(&:id)).to include(2)
      end

      it 'app03 is returned' do
        apps = subject.applications
        expect(apps.map(&:id)).to include(3)
      end
    end
  end
end
