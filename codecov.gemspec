# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name                  = 'codecov'
  s.authors               = ['codecov']
  s.description           = 'hosted code coverage'
  s.email                 = ['hello@codecov.io']
  s.files                 = ['lib/codecov.rb']
  s.homepage              = 'https://github.com/codecov/codecov-ruby'
  s.license               = 'MIT'
  s.platform              = Gem::Platform::RUBY
  s.require_paths         = ['lib']
  s.required_ruby_version = '>=2.4'
  s.summary               = 'hosted code coverage ruby/rails reporter'
  s.test_files            = ['test/test_codecov.rb']
  s.version               = '0.2.6'

  s.add_dependency 'colorize'
  s.add_dependency 'json'
  s.add_dependency 'simplecov'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-ci'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'webmock'
end
