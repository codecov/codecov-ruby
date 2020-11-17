# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name                  = 'codecov'
  s.authors               = ['Steve Peak', 'Tom Hu']
  s.summary               = 'Hosted code coverage'
  s.description           = 'Hosted code coverage Ruby reporter.'
  s.email                 = ['hello@codecov.io']
  s.files                 = ['lib/codecov.rb']
  s.homepage              = 'https://github.com/codecov/codecov-ruby'
  s.license               = 'MIT'
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '~> 2.4'
  s.version               = '0.2.12'

  s.add_dependency 'simplecov', '~> 0.18.0'

  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'minitest-ci', '~> 3.0'
  s.add_development_dependency 'mocha', '~> 1.0'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rubocop', '~> 1.0'
  s.add_development_dependency 'webmock', '~> 3.0'
end
