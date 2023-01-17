source 'https://rubygems.org'

# Specify your gem's dependencies in 3scale.gemspec
gemspec

group :development do
  gem 'license_finder', '~> 7.0'
  gem 'pry'
  # rubyzip is a transitive depencency from license_finder with vulnerability on < 1.3.0
  gem 'rubyzip', '>= 1.3.0'
end

group :test do
  gem 'codecov', require: false
end
