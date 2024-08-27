module ThreeScaleToolbox
  class Remotes
    class << self
      def from_uri(uri_str)
        uri = Helper.parse_uri(uri_str)

        raise ThreeScaleToolbox::InvalidUrlError, "invalid url: #{uri_str}" unless uri.kind_of?(URI::HTTP)

        authentication = uri.user
        uri.user = ''
        { authentication: authentication, endpoint: uri.to_s }
      end
    end

    def initialize(config)
      @config = config
    end

    ##
    # Fetch remotes
    # Perform validation
    #
    def all
      rmts = (config.data :remotes) || {}
      raise_invalid unless validate(rmts)
      rmts
    end

    def add_uri(name, uri)
      remote = self.class.from_uri(uri)
      add(name, remote)
    end

    def add(key, remote)
      update do |rmts|
        rmts.tap { |r| r[key] = remote }
      end
    end

    def delete(key, &block)
      value = nil
      update do |rmts|
        # block should return rmts
        # but main method should return deleted value
        rmts.tap do |r|
          value = if block_given?
                    r.delete(key, &block)
                  else
                    r.delete(key)
                  end
        end
      end
      value
    end

    def fetch(name)
      all.fetch(name) { raise_not_found(name) }
    end

    private

    attr_reader :config

    ##
    # Update remotes
    # Perform validation
    #
    def update
      config.update(:remotes) do |rmts|
        yield(rmts || {}).tap do |new_rmts|
          raise_invalid unless validate(new_rmts)
        end
      end
    end

    def raise_not_found(remote_str)
      raise ThreeScaleToolbox::Error, "remote '#{remote_str}' not found from config file #{config.config_file}"
    end

    def raise_invalid
      raise ThreeScaleToolbox::Error, "invalid remote configuration from config file #{config.config_file}"
    end

    def valid?(remote)
      remote.is_a?(Hash) && remote.key?(:endpoint) && remote.key?(:authentication)
    end

    def validate(remotes)
      case remotes
      when Hash then remotes.values.all?(&method(:valid?))
      else false
      end
    end
  end
end
