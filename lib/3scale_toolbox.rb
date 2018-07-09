require '3scale_toolbox/version'
require '3scale_toolbox/cli'

module ThreeScaleToolbox
  def self.load_commands
    commands.map { |plugin_path| load_command plugin_path }
  end

  def self.load_command(plugin_path)
    require plugin_path
    command_name = File.basename plugin_path, '_command.rb'
    msg = "command_#{command_name}_definition"
    Commands.send msg if Commands.respond_to?(msg)
  end

  def self.commands
    require 'rubygems' unless defined? Gem
    Gem.find_files('3scale_toolbox/commands/*_command.rb')
  end
end
