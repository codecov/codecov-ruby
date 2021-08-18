# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end
require_relative '../lib/codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov if ENV['CI'] == 'true'
Codecov.pass_ci_if_error = false

require 'minitest/autorun'
require 'mocha/minitest'
require 'webmock/minitest'
