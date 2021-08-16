require '3scale_toolbox/commands/3scale_command'
require '3scale_toolbox/commands/help_command'
require '3scale_toolbox/commands/import_command'
require '3scale_toolbox/commands/update_command'
require '3scale_toolbox/commands/remote_command'
require '3scale_toolbox/commands/plans_command'
require '3scale_toolbox/commands/metrics_command'
require '3scale_toolbox/commands/methods_command'
require '3scale_toolbox/commands/service_command'
require '3scale_toolbox/commands/copy_command'
require '3scale_toolbox/commands/activedocs_command'
require '3scale_toolbox/commands/account_command'
require '3scale_toolbox/commands/proxy_config_command'
require '3scale_toolbox/commands/policy_registry_command'
require '3scale_toolbox/commands/application_command'
require '3scale_toolbox/commands/backend_command'
require '3scale_toolbox/commands/product_command'
require '3scale_toolbox/commands/policies_command'

module ThreeScaleToolbox
  module Commands
    BUILTIN_COMMANDS = [ # :nodoc:
      ThreeScaleToolbox::Commands::HelpCommand,
      ThreeScaleToolbox::Commands::CopyCommand,
      ThreeScaleToolbox::Commands::ImportCommand,
      ThreeScaleToolbox::Commands::UpdateCommand,
      ThreeScaleToolbox::Commands::RemoteCommand::RemoteCommand,
      ThreeScaleToolbox::Commands::PlansCommand,
      ThreeScaleToolbox::Commands::MetricsCommand,
      ThreeScaleToolbox::Commands::MethodsCommand,
      ThreeScaleToolbox::Commands::ServiceCommand,
      ThreeScaleToolbox::Commands::ActiveDocsCommand,
      ThreeScaleToolbox::Commands::AccountCommand,
      ThreeScaleToolbox::Commands::ProxyConfigCommand,
      ThreeScaleToolbox::Commands::PolicyRegistryCommand,
      ThreeScaleToolbox::Commands::ApplicationCommand,
      ThreeScaleToolbox::Commands::BackendCommand,
      ThreeScaleToolbox::Commands::ProductCommand,
      ThreeScaleToolbox::Commands::PoliciesCommand,
    ].freeze
  end
end
