require 'rubygems'
require 'bundler/setup'

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter "/test/"
end
require 'codecov'
if ENV['CI'] == 'true'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'minitest/autorun'
require 'mocha/setup'
