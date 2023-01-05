# frozen_string_literal: true

require_relative 'lib/codecov/version'

Gem::Specification.new do |s|
  s.name                  = 'codecov'
  s.authors               = ['Steve Peak', 'Tom Hu']
  s.summary               = 'Hosted code coverage'
  s.description           = 'Hosted code coverage Ruby reporter.'
  s.email                 = ['hello@codecov.io']
  s.files                 = Dir[
    'lib/**/*.rb', 'README.md', 'LICENSE', 'CHANGELOG.md'
  ]
  s.license               = 'MIT'
  s.version               = ::Codecov::VERSION

  github_uri = 'https://github.com/codecov/codecov-ruby'

  s.homepage = github_uri

  s.metadata = {
    'bug_tracker_uri' => "#{github_uri}/issues",
    'changelog_uri' => "#{github_uri}/blob/v#{s.version}/CHANGELOG.md",
    'documentation_uri' =>
      "http://www.rubydoc.info/gems/#{s.name}/#{s.version}",
    'homepage_uri' => s.homepage,
    'source_code_uri' => github_uri
  }

  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.4', '< 4'

  s.add_dependency 'simplecov', '>= 0.15', '< 0.23'

  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'mocha', '~> 1.0'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rubocop', '~> 1.0'
  s.add_development_dependency 'webmock', '~> 3.0'
end
