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
              usage       'list <remote>'
              summary     'list accounts'
              description 'List all accounts'

              param       :remote

              runner ListAccountSubcommand
            end
          end

  	  ACCOUNTS_FIELDS_TO_SHOW = %w[ id state created_at org_name ]

          def run
		  accounts = threescale_client(arguments[:remote]).list_accounts
		  printer.print_collection accounts
          end
	  
	  def printer
            options.fetch(:output, CLI::CustomTablePrinter.new(ACCOUNTS_FIELDS_TO_SHOW))
          end
        end
      end
    end
  end
end
