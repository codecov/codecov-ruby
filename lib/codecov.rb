# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'
require 'simplecov'
require 'zlib'

require_relative 'codecov/formatter'
require_relative 'codecov/uploader'

class SimpleCov::Formatter::Codecov
  def format(result, disable_net_blockers = true)
    report = Codecov::Simplecov::Formatter.format(result)
    Codecov::Uploader(report, disable_net_blockers)
  end
end
