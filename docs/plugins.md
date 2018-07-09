# Developing 3scale Toolbox CLI plugins

3scale Toolbox CLI is based on [cri](https://github.com/ddfreyne/cri) library for building command line tools.
Plugin system also uses [cri](https://github.com/ddfreyne/cri) to leverage easy to develop, flexible and extensible plugin system.

3scale Toolbox will load plugins installed in gems or $LOAD_PATH. Plugins are discovered via *Gem::find_files*, then loaded.
Few requirements must be met for a plugin to be loaded:
* Plugin must be named `${plugin_name}_command.rb` and placed at `/3scale_toolbox/commands/` from your root load path
* Plugin must implement module function `ThreeScaleToolbox::Commands.command_${plugin_name}_definition` and return instance of `Cri::Command` from [cri](https://github.com/ddfreyne/cri)

Nothing better than `simple Hello World plugin` to illustrate.

```
$ cat lib/3scale_toolbox/commands/foo_command.rb
module ThreeScaleToolbox
  module Commands
    def self.command_foo_definition
      Cri::Command.define do
        name        'foo'
        usage       'foo [options]'
        summary     'foo command'
        description 'This command does a lot of stuff.'

        flag :h, :help, 'show help for this command' do |_, cmd|
          puts cmd.help
          exit 0
        end

        run do |opts, args, cmd|
          puts "Hello World"
        end
      end
    end
  end
end

$ RUBYOPT=-Ilib 3scale foo
Hello World

$ RUBYOPT=-Ilib 3scale foo -h
NAME
    foo - foo command

USAGE
    3scale foo [options]

DESCRIPTION
    This command does a lot of stuff.

OPTIONS
    -h --help         show help for this command

OPTIONS FOR 3SCALE
    -v --version      Prints the version of this command
```

Your plugin help is also available using builtin *help* command

```
$ RUBYOPT=-Ilib 3scale help foo
NAME
    foo - foo command

USAGE
    3scale foo [options]

DESCRIPTION
    This command does a lot of stuff.

OPTIONS
    -h --help         show help for this command

OPTIONS FOR 3SCALE
    -v --version      Prints the version of this command
```

Now, package your plugin as a [gem](https://guides.rubygems.org/make-your-own-gem/) and let us know about it.

## Existing Plugins
