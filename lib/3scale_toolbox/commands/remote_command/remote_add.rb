module ThreeScaleToolbox
  module Commands
    module RemoteCommand
      class RemoteAddSubcommand < Cri::CommandRunner
        include ThreeScaleToolbox::Command

        def self.command
          Cri::Command.define do
            name        'add'
            usage       'add <name> <url>'
            summary     'remote add'
            description 'Add new remote to the list'
            param       :remote_name
            param       :remote_url
            runner RemoteAddSubcommand
          end
        end

        def run
          # 'arguments' cannot be converted to Hash
          add_remote arguments[:remote_name], arguments[:remote_url]
        end

        private

        def validate_remote_name(name)
          raise ThreeScaleToolbox::Error, 'remote name already exists.' if remotes.all.key?(name)
        end

        def validate_remote(remote_url_str)
          uri_obj = ThreeScaleToolbox::Helper.parse_uri(remote_url_str)
          raise ThreeScaleToolbox::InvalidUrlError, "invalid url: #{remote_url_str}" unless uri_obj.kind_of?(URI::HTTP)

          threescale_client(remote_url_str).list_accounts
        rescue ThreeScale::API::HttpClient::ForbiddenError
          raise ThreeScaleToolbox::Error, 'remote not valid'
        end

        def add_remote(remote_name, remote_url)
          validate_remote_name remote_name
          validate_remote remote_url
          remotes.add_uri(remote_name, remote_url)
        end
      end
    end
  end
end
