require 'cri'
require '3scale_toolbox/base_command'

module ThreeScaleToolbox
  module Commands
    module AccountCommand
      module List
        class ListAccountSubcommand < Cri::CommandRunner
          include ThreeScaleToolbox::Command

          def self.command
            Cri::Command.define do
              name        'list'
              usage       'list'
              summary     'list accounts'
              description 'List all accounts'

 #             option      :a, :'print-all', 'Print all the account info', argument: :forbidden
              param       :remote
#              param       :text

              runner ListAccountSubcommand
            end
          end

          def run
    		puts threescale_client(arguments[:remote]).list_accounts
          end
        end
      end
    end
  end
end
