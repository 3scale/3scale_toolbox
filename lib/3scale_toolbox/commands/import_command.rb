require 'cri'
require '3scale_toolbox/base_command'
require '3scale_toolbox/commands/import_command/import_csv'

module ThreeScaleToolbox
  module Commands
    module ImportCommand
      extend ThreeScaleToolbox::Command
      def self.command
        Cri::Command.define do
          name        'import'
          usage       'import <command> [options]'
          summary     '3scale import super command'
          description '3scale import super command.'

          flag :h, :help, 'show help for this command' do |_, cmd|
            puts cmd.help
            exit 0
          end
        end
      end
      add_subcommand(ImportCsvSubcommand)
    end
  end
end
