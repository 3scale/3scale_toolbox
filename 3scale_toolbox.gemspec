# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require '3scale_toolbox/version'

Gem::Specification.new do |spec|
  spec.name          = '3scale_toolbox'
  spec.version       = ThreeScaleToolbox::VERSION
  spec.licenses      = ['MIT']
  spec.authors       = ['Miguel Soriano', 'Eguzki Astiz Lezaun']
  spec.email         = ['msoriano@redhat.com', 'eastizle@redhat.com']

  spec.summary       = %q{3scale Toolbox.}
  spec.description   = %q{3scale tools to manage your API from the terminal.}
  spec.homepage      = 'https://github.com/3scale/3scale_toolbox'

  spec.files         = Dir['{lib}/**/*.rb']
  spec.files         += Dir['{exe,resources}/*']
  spec.files         << 'README.md'
  spec.files         << 'licenses.xml'
  spec.files         << 'LICENSE'
  spec.files         << 'NOTICE'
  # There is a bug in gem 2.7.6 and __FILE__ cannot be used.
  # It is expanded in rake release task with full path on the building host
  spec.files         << '3scale_toolbox.gemspec'

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'webmock', '~> 3.4'
  spec.required_ruby_version = '>= 3.0'

  spec.add_dependency '3scale-api', '~> 1.6'
  spec.add_dependency 'cri', '~> 2.15'
  spec.add_dependency 'json-schema', '~> 2.8'
  spec.add_dependency 'oas_parser', '~> 0.20'
  spec.add_dependency 'activesupport', '>= 6', '< 8'
end
