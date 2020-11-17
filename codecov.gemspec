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
  s.require_paths         = ['lib']
  s.required_ruby_version = '>=2.4'
  s.test_files            = ['test/test_codecov.rb']
  s.version               = '0.2.12'

  s.add_dependency 'simplecov'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-ci'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'webmock'
end
