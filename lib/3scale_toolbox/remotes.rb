module ThreeScaleToolbox
  module Remotes
    def self.included(base)
      base.extend(ClassMethods)
    end
    module ClassMethods
    end

    ##
    # Fetch remote list
    # Perform validation
    #
    def remotes
      rmts = config.data :remotes
      raise_invalid_remote unless validate_remotes?(rmts)

      rmts || {}
    end

    def update_remotes
      config.update(:remotes) do |rmts|
        yield(rmts || {})
      end
    end

    def parse_remote_uri(remote_url_str)
      # should raise error on invalid urls
      remote_uri_obj = URI(remote_url_str)
      auth_key = remote_uri_obj.user
      remote_uri_obj.user = ''
      endpoint = remote_uri_obj.to_s
      { auth_key: auth_key, endpoint: endpoint }
    end

    def validate_remote(endpoint:, auth_key:)
      client = ThreeScale::API.new(
        endpoint: endpoint,
        provider_key: auth_key,
        verify_ssl: verify_ssl
      )
      begin
        client.list_services
      rescue ThreeScale::API::HttpClient::ForbiddenError
        raise ThreeScaleToolbox::Error, 'remote not valid'
      end
    end

    def get_remote(origin)
      remote = parse_remote_uri origin
      ThreeScale::API.new(
        endpoint:     remote[:endpoint],
        provider_key: remote[:auth_key],
        verify_ssl: verify_ssl
      )
    end

    private

    def raise_invalid_remote
      raise ThreeScaleToolbox::Error, "invalid remote configuration from config file #{config_file}"
    end

    def valid_remote?(remote)
      remote.is_a?(Hash) \
        && remote.key?(:endpoint) \
        && remote.key?(:auth_key)
    end

    def validate_remotes?(remotes)
      case remotes
      when nil then true
      when Hash then remotes.values.all?(&method(:valid_remote?))
      else false
      end
    end
  end
end
