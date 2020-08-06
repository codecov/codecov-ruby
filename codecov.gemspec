# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name               = 'codecov'
  s.version            = '0.2.3'
  s.platform           = Gem::Platform::RUBY
  s.authors            = ['codecov']
  s.email              = ['hello@codecov.io']
  s.description        = 'hosted code coverage'
  s.homepage           = 'https://github.com/codecov/codecov-ruby'
  s.summary            = 'hosted code coverage ruby/rails reporter'
  s.license            = 'MIT'
  s.files              = ['lib/codecov.rb']
  s.test_files         = ['test/test_codecov.rb']
  s.require_paths      = ['lib']

  s.add_dependency 'colorize'
  s.add_dependency 'json'
  s.add_dependency 'simplecov'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'webmock'
end
