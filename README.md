# 3scale toolbox
[![CircleCI](https://circleci.com/gh/3scale/3scale_toolbox.svg?style=svg)](https://circleci.com/gh/3scale/3scale_toolbox)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0)
[![GitHub release](https://img.shields.io/github/v/release/3scale/3scale_toolbox.svg)](https://github.com/3scale/3scale_toolbox/releases/latest)
[![codecov](https://codecov.io/gh/3scale/3scale_toolbox/branch/main/graph/badge.svg?token=ojinl2NVv5)](https://codecov.io/gh/3scale/3scale_toolbox)

## Description
3scale toolbox is a set of tools to help you manage your 3scale product. Using the [3scale API Ruby Client](https://github.com/3scale/3scale-api-ruby).

## Table of contents
* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
   * [Copy service](docs/copy-service.md)
   * [Copy backend](docs/copy-backend.md)
   * [Copy product](docs/copy-product.md)
   * [Export/Import product](docs/export-import-product.md)
   * [Import from CSV](docs/import-csv.md)
   * [Import from OpenAPI definition](docs/openapi.md)
   * [Export/Import Application Plan](docs/export-import-app-plan.md)
   * Create, Apply, List, Show, Delete [Application plan](docs/app-plan.md)
   * Create, Apply, List, Delete [Metric](docs/metric.md)
   * Create, Apply, List, Delete [Method](docs/method.md)
   * Create, Apply, List, Show, Delete [Service](docs/service.md)
   * Create, Apply, List, Delete [ActiveDocs](docs/activedocs.md)
   * Show, Update, Deploy [APIcast proxy settings](docs/proxy.md)
   * List, Show, Promote, Export [Staging/Production Proxy Configuration](docs/proxy-config.md)
   * [Copy Policy Registry](docs/copy-policy-registry.md)
   * Create, Apply, List, Show, Delete, Suspend, Resume [Applications](docs/applications.md)
   * [Export/Import Product Policy Chain](docs/export-import-policy-chain.md)
   * [Remotes](docs/remotes.md)
* [Development](#development)
   * [Testing](#testing)
   * [Develop your own core command](#develop-core-command)
   * [Licenses](#licenses)
* [Plugins](#plugins)
* [Error Reporting](docs/errors.md)
* [Troubleshooting](#troubleshooting)
* [Contributing](#contributing)

## Requirements
Supported Ruby interpreters

* MRI 3.0

## Installation
Install the toolbox:

```
$ gem install 3scale_toolbox
```

The [3scale toolbox packaging repo](https://github.com/3scale/3scale_toolbox_packaging)
provides packages and installation/deployment steps for the following platforms:
* CentOS/Fedora
* Ubuntu/Debian
* Mac OS X
* Windows
* Docker
* Kubernetes / Openshift

## Usage

```shell
$ 3scale help
NAME
    3scale - 3scale toolbox

USAGE
    3scale <sub-command> [options]

DESCRIPTION
    3scale toolbox to manage your API from the terminal.

COMMANDS
    account              account super command
    activedocs           activedocs super command
    application          application super command
    application-plan     application-plan super command
    backend              backend super command
    copy                 copy super command
    help                 show help
    import               import super command
    method               method super command
    metric               metric super command
    policies             policies super command
    policy-registry      policy-registry super command
    product              product super command
    proxy                proxy super command
    proxy-config         proxy-config super command
    remote               remotes super command
    service              services super command

OPTIONS
    -c --config-file=<value>      3scale toolbox configuration file (default:
                                  $HOME/.3scalerc.yaml)
       --disable-keep-alive       Disable keep alive HTTP connection mode
    -h --help                     show help for this command
    -k --insecure                 Proceed and operate even for server
                                  connections otherwise considered insecure
    -v --version                  Prints the version of this command
       --verbose                  Verbose mode
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec 3scale` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Testing

To run all tests run `rake`.

There are two kinds of tests:
* unit (see [spec/unit](spec/unit))
```bash
rake spec:unit
```

* integration (see [spec/integration](spec/integration)).
```bash
rake spec:integration
```

Integration tests can be run locally or against a real 3scale account.
When details of the account are set via environment variables,
integration tests are run against the given account.
Otherwise, tests are run locally with mocked 3scale clients.

The easiest way to set everything up is it to have a `.env` file in the root of the project with the following environment variables (set your own values):

```
ENDPOINT=https://your-domain-admin.3scaledomain
PROVIDER_KEY=abc123
VERIFY_SSL=true (by default true)
```
### Develop Core Command

Very simple core command to list existing services.
Helps to illustrate basic command code structure and helper methods to deal with remotes.

```
$ cat lib/3scale_toolbox/commands/service_list_command.rb
module ThreeScaleToolbox
  module Commands
    class ServiceListCommand < Cri::CommandRunner
      include ThreeScaleToolbox::Command

      def self.command
        Cri::Command.define do
          name        'service_list'
          usage       'service_list <3scale_remote>'
          summary     'service list'
          description 'list available services'
          param       :remote
          runner ServiceListCommand
        end
      end

      def run
        puts threescale_client(arguments[:remote]).list_services
      end
    end
  end
end
```
A few things worth highlighting:
- Your module must include the *ThreeScaleToolbox::Command* module. It allows your command to be added to the toobox command tree.
- You must implement the `command` module function and return an instance of `Cri::Command` from [cri](https://github.com/ddfreyne/cri)
- `threescale_client` helper method returns *3scale API* client instance. All the process remote parsing, fetching from the remote list and client instantiation is done out of the box.

Then register the core command in `lib/3scale_toolbox/commands.rb`
```
--- a/lib/3scale_toolbox/commands.rb
+++ b/lib/3scale_toolbox/commands.rb
@@ -4,6 +4,7 @@ require '3scale_toolbox/commands/copy_command'
 require '3scale_toolbox/commands/import_command'
 require '3scale_toolbox/commands/remote_command'
+require '3scale_toolbox/commands/service_list_command'

 module ThreeScaleToolbox
   module Commands
@@ -12,7 +13,8 @@ module ThreeScaleToolbox
       ThreeScaleToolbox::Commands::CopyCommand,
       ThreeScaleToolbox::Commands::ImportCommand,
-      ThreeScaleToolbox::Commands::RemoteCommand::RemoteCommand
+      ThreeScaleToolbox::Commands::RemoteCommand::RemoteCommand,
+      ThreeScaleToolbox::Commands::ServiceListCommand
     ].freeze
   end
 end
```

Running the new core command:

```shell
$ 3scale service_list my-3scale-instance
{ ... }
```
### Licenses

It is a requirement that we include a file describing all the licenses used in the product, so that users can examine it.

Run `rake license_finder:check` to check licenses when dependencies change.

Run `rake license_finder:report > licenses.xml` to update licenses file.

## Plugins

As of 3scale Toolbox 0.5.0, 3scale Toolbox will load plugins installed in gems or $LOAD_PATH. Plugins are discovered via Gem::find_files then loaded.
Install, uninstall and update plugins using tools like [RubyGems](https://guides.rubygems.org/rubygems-basics/) and/or [Bundler](https://bundler.io/).

[Make your own plugin](docs/plugins.md)

## Troubleshooting

* [SSL errors](docs/ssl_errors.md): If you run into SSL issues with the toolbox, you can take actions to resolve them.

## Contributing

If you are interested in contributing to 3scale Toolbox, please refer to instructions available [here](docs/contributing.md)

