# 3scale toolbox

3scale toolbox is a set of tools to help you manage your 3scale product. Using the [3scale API Ruby Client](https://github.com/3scale/3scale-api-ruby).

## Installation


Install the CLI:

    $ gem install 3scale_toolbox

## Usage

```shell
3scale help
```

### Copy a service

Will create a new service, copy existing methods, metrics, application plans and their usage limits.

```shell
3scale copy service NUMBER --source=https://provider_key@foo-admin.3scale.net --destination=https://provider_key@foo2-admin.3scale.net
```

### Import from CSV

Will create a new services, metrics, methods and mapping rules.

```shell
3scale import csv --destination=https://provider_key@user-admin.3scale.net --file=examples/import_example.csv
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec 3scale` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Plugins

As of 3scale Toolbox 0.5.0, 3scale Toolbox will load plugins installed in gems or $LOAD_PATH. Plugins are discovered via Gem::find_files then loaded.
Install, uninstall and update plugins using tools like [RubyGems](https://guides.rubygems.org/rubygems-basics/) and/or [Bundler](https://bundler.io/).

[Make your own plugin](docs/plugins.md)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/3scale/3scale_toolbox.

