require 'rubygems'
require 'bundler/setup'

require 'simplecov-cobertura'
SimpleCov.start 'rails' do
  add_filter "/test/"
end
require 'codecov'

SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter


require 'minitest/autorun'
require 'mocha/setup'
