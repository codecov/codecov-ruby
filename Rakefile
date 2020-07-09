# frozen_string_literal: true

require 'bundler'
require 'rubygems'
require 'rake/testtask'

helper = Bundler::GemHelper.new
helper.install_gem
Bundler::GemHelper.install_tasks

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/test_*.rb'
  test.verbose = true
end

task default: :test
