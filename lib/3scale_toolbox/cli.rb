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
    Cri::Command.define do
      name        '3scale'
      usage       '3scale <command> [options]'
      summary     '3scale CLI Toolbox'
      description '3scale CLI tools to manage your API from the terminal.'

      flag :h, :help, 'show help for this command' do |_, cmd|
        puts cmd.help
        exit 0
      end

      flag :v, :version, 'Prints the version of this command' do |_, _|
        puts ThreeScaleToolbox::VERSION
        exit 0
      end
    end
  end
end
