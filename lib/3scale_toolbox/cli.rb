require 'cri'

class ThreeScaleToolbox::Runner
  ##
  # Run the gem command with the following arguments.
  def run(args)
    root_cmd = root_command
    ThreeScaleToolbox.load_commands.each { |command| root_cmd.add_command command }
    root_cmd.run args
  end

  def root_command
    basic_command.tap { |command| command.add_command Cri::Command.new_basic_help }
  end

  def basic_command
    Cri::Command.define do
      name        '3scale'
      usage       '3scale <command> [options]'
      summary     '3scale CLI Toolbox'
      description '3scale CLI tools to manage your API from the terminal.'

      flag :v, :version, 'Prints the version of this command' do |_, _|
        puts ThreeScaleToolbox::VERSION
        exit 0
      end
    end
  end
end
