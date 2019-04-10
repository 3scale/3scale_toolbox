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

  spec.summary       = %q{3scale Toolbox.}
  spec.description   = %q{3scale tools to manage your API from the terminal.}
  spec.homepage      = 'https://github.com/3scale/3scale_toolbox'

  spec.files         = Dir['{lib}/**/*.rb'] + %w[README.md] + Dir['exe/*'] + Dir['resources/*']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.8'
  spec.add_development_dependency 'webmock', '~> 3.4'
  spec.required_ruby_version = '>= 2.4'

  spec.add_dependency '3scale-api', '~> 0.1.9'
  spec.add_dependency 'cri', '~> 2.15'
  spec.add_dependency 'json-schema', '~> 2.8'
end
