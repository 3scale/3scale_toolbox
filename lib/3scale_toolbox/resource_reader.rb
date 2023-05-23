module ThreeScaleToolbox
  module ResourceReader
    ##
    # Load resource from different types of sources.
    # Supported types are: file, URL, stdin
    # Loaded content is returned
    def load_resource(resource, verify_ssl)
      # Json format is parsed as well
      YAML.safe_load(read_content(resource, verify_ssl))
    rescue Psych::SyntaxError => e
      raise ThreeScaleToolbox::Error, "JSON/YAML validation failed: #{e.message}"
    end

    ##
    # Reads resources from different types of sources.
    # Supported types are: file, URL, stdin
    # Resource raw content is returned
    def read_content(resource, verify_ssl)
      case resource
      when '-'
        read_stdin(resource)
      when /\A#{URI::DEFAULT_PARSER.make_regexp}\z/
        read_url(resource, verify_ssl)
      when StringIO
        read_stringio(resource)
      else
        read_file(resource)
      end
    end

    # Detect format from file extension
    def read_file(filename)
      raise ThreeScaleToolbox::Error, "File not found: #{filename}" unless File.file?(filename)
      raise ThreeScaleToolbox::Error, "File not readable: #{filename}" unless File.readable?(filename)

      File.read(filename)
    end

    def read_stdin(_resource)
      STDIN.read
    end

    def read_url(resource, verify_ssl)
      endpoint = URI.parse(resource)
      http_client = Net::HTTP.new(endpoint.host, endpoint.port)
      http_client.use_ssl = endpoint.is_a?(URI::HTTPS)
      http_client.verify_mode = OpenSSL::SSL::VERIFY_NONE unless verify_ssl

      response = http_client.get(endpoint)
      case response
      when Net::HTTPSuccess then response.body
      else raise ThreeScaleToolbox::Error, "could not download resource: #{response.body}"
      end
    end

    def read_stringio(resource)
      resource.string
    end
  end
end
