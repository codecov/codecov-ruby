# frozen_string_literal: true

require 'simplecov'

require_relative 'version'

module Codecov::SimpleCov
  class Formatter
    def self.format(report)
      result = {
        'meta' => {
          'version' => "codecov-ruby/v#{::Codecov::VERSION}"
        }
      }
      result.update(result_to_codecov(report))
      result
    end

    private

    # Format SimpleCov coverage data for the Codecov.io API.
    #
    # @param result [SimpleCov::Result] The coverage data to process.
    # @return [Hash]
    def self.result_to_codecov(result)
      {
        'codecov' => result_to_codecov_report(result),
        'coverage' => result_to_codecov_coverage(result),
        'messages' => result_to_codecov_messages(result)
      }
    end

    def self.result_to_codecov_report(result)
      report = file_network.join("\n").concat("\n")
      report.concat({ 'coverage' => result_to_codecov_coverage(result) }.to_json)
    end

    def self.file_network
      invalid_file_types = [
        'woff', 'eot', 'otf', # fonts
        'gif', 'png', 'jpg', 'jpeg', 'psd', # images
        'ptt', 'pptx', 'numbers', 'pages', 'md', 'txt', 'xlsx', 'docx', 'doc', 'pdf', 'csv', # docs
        'yml', 'yaml', '.gitignore'
      ].freeze

      invalid_directories = [
        'node_modules/',
        'public/',
        'storage/',
        'tmp/',
        'vendor/'
      ]

      puts [green('==>'), 'Appending file network'].join(' ')
      network = []
      Dir['**/*'].keep_if do |file|
        if File.file?(file) && !file.end_with?(*invalid_file_types) && invalid_directories.none? { |dir| file.include?(dir) }
          network.push(file)
        end
      end

      network.push('<<<<<< network')
      network
    end

    # Format SimpleCov coverage data for the Codecov.io coverage API.
    #
    # @param result [SimpleCov::Result] The coverage data to process.
    # @return [Hash<String, Array>]
    def self.result_to_codecov_coverage(result)
      result.files.each_with_object({}) do |file, memo|
        memo[shortened_filename(file)] = file_to_codecov(file)
      end
    end

    # Format SimpleCov coverage data for the Codecov.io messages API.
    #
    # @param result [SimpleCov::Result] The coverage data to process.
    # @return [Hash<String, Hash>]
    def self.result_to_codecov_messages(result)
      result.files.each_with_object({}) do |file, memo|
        memo[shortened_filename(file)] = file.lines.each_with_object({}) do |line, lines_memo|
          lines_memo[line.line_number.to_s] = 'skipped' if line.skipped?
        end
      end
    end

    # Format coverage data for a single file for the Codecov.io API.
    #
    # @param file [SimpleCov::SourceFile] The file to process.
    # @return [Array<nil, Integer>]
    def self.file_to_codecov(file)
      # Initial nil is required to offset line numbers.
      [nil] + file.lines.map do |line|
        if line.skipped?
          nil
        else
          line.coverage
        end
      end
    end

    # Get a filename relative to the project root. Based on
    # https://github.com/colszowka/simplecov-html, copyright Christoph Olszowka.
    #
    # @param file [SimpleCov::SourceFile] The file to use.
    # @return [String]
    def self.shortened_filename(file)
      file.filename.gsub(/^#{SimpleCov.root}/, '.').gsub(%r{^\./}, '')
    end

    # Convenience color methods
    def self.black(str)
      str.nil? ? '' : "\e[30m#{str}\e[0m"
    end

    def self.red(str)
      str.nil? ? '' : "\e[31m#{str}\e[0m"
    end

    def self.green(str)
      str.nil? ? '' : "\e[32m#{str}\e[0m"
    end
  end
end
