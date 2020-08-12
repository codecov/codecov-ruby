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
require 'mocha/minitest'
require 'webmock/minitest'

require 'minitest/ci'

if ENV["CIRCLECI"]
  Minitest::Ci.report_dir = "#{ENV["CIRCLE_TEST_REPORTS"]}/reports"
end
