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

 #             option      :a, :'print-all', 'Print all the account info', argument: :forbidden
              param       :remote
#              param       :text

              runner ListAccountSubcommand
            end
          end

#{"id"=>4, "created_at"=>"2021-04-15T06:21:55Z", "updated_at"=>"2021-04-16T06:21:28Z", "credit_card_stored"=>false, "monthly_billing_enabled"=>true, "monthly_charging_enabled"=>true, "state"=>"approved", "links"=>[{"rel"=>"self", "href"=>"https://3scale-admin.3scale.apps.delorean.globalshared-dev.seat.cloud.vwgroup.com/admin/api/accounts/4"}, {"rel"=>"users", "href"=>"https://3scale-admin.3scale.apps.delorean.globalshared-dev.seat.cloud.vwgroup.com/admin/api/accounts/4/users"}], "org_name"=>"VWFS/gdpr"#}

  	  ACCOUNTS_FIELDS_TO_SHOW = %w[ id state created_at org_name ]

          def run
		  accounts = threescale_client(arguments[:remote]).list_accounts
		  printer.print_collection accounts

    #		puts threescale_client(arguments[:remote]).list_accounts
          end
	  
	  def printer
            # keep backwards compatibility
            options.fetch(:output, CLI::CustomTablePrinter.new(ACCOUNTS_FIELDS_TO_SHOW))
          end
        end
      end
    end
  end
end
