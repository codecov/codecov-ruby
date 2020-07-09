# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end
require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov if ENV['CI'] == 'true'

require 'minitest/autorun'
require 'mocha/setup'
