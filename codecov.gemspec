# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)
require 'codecov'

Gem::Specification.new do |s|
  s.name               = "codecov"
  s.version            = VERSION
  s.platform           = Gem::Platform::RUBY
  s.authors            = ["codecov"]
  s.email              = ["hello@codecov.io"]
  s.description        = %q{hosted code coverage}
  s.homepage           = %q{https://github.com/codecov/codecov-ruby}
  s.summary            = %q{hosted code coverage ruby/rails reporter}
  s.rubyforge_project  = "codecov"
  s.files              = ["lib/codecov.rb"]
  s.test_files         = ["test/test_codecov.rb"]
  s.require_paths      = ["lib"]
  
  s.add_dependency "url"
  s.add_dependency "json"
  s.add_dependency "simplecov-html"
  s.add_development_dependency "rake"

end
