require 'rubygems'
require 'bundler/setup'

require 'simplecov'
SimpleCov.start
require 'codecov'
if ENV['CI'] == 'true'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'test/unit'
require 'mocha/setup'

class Test::Unit::TestCase
end
