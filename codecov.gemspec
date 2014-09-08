Gem::Specification.new do |s|
  s.name               = "codecov"
  s.version            = "0.0.1"
  s.platform           = Gem::Platform::RUBY
  s.authors            = ["codecov"]
  s.email              = ["hello@codecov.io"]
  s.description        = %q{hosted code coverage}
  s.homepage           = %q{https://github.com/codecov/codecov-ruby}
  s.summary            = %q{hosted code coverage ruby/rails reporter}
  s.rubyforge_project  = "codecov"
  s.files              = ["lib/codecov.rb"]
  s.test_files         = ["test/helper.rb", "test/test_codecov.rb"]
  s.require_paths      = ["lib"]
  
  s.add_dependency "url"
  s.add_dependency "json"
  s.add_dependency "simplecov"

  s.add_development_dependency "rake"

end
