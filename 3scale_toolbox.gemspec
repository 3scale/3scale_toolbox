# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require '3scale_toolbox/version'

Gem::Specification.new do |spec|
  spec.name          = '3scale_toolbox'
  spec.version       = ThreeScaleToolbox::VERSION
  spec.licenses      = ['MIT']
  spec.authors       = ['Michal Cichra', 'Eguzki Astiz Lezaun']
  spec.email         = ['michal@3scale.net', 'eastizle@redhat.com']

  spec.summary       = %q{3scale CLI Toolbox.}
  spec.description   = %q{3scale CLI tools to manage your API from the terminal.}
  spec.homepage      = 'https://github.com/3scale/3scale_toolbox'

  spec.files         = Dir['{lib}/**/*.rb'] + %w[README.md] + Dir['exe/*']
  # Gemfile* and gemspec are included here to support
  # running Bundler at gem install time.
  spec.files         << 'Gemfile'
  spec.files         << 'Gemfile.lock'
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency '3scale-api', '~> 0.1'
  spec.add_dependency 'cri', '~> 2.10'
end
