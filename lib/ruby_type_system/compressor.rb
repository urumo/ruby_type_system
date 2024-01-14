# frozen_string_literal: true

require "debug"

module RubyTypeSystem
  class Compressor
    attr_reader :file_path, :already_required

    def initialize(file_path)
      raise "File does not exist" unless File.exist?(file_path)

      @file_path = file_path
      @already_required = []
    end

    def compress
      compressed_code = process_file(file_path)
      File.write("dist/compressed.rb", compressed_code)
    end

    private

    def process_file(path)
      code = File.read(path)

      code.lines.map do |line|
        if line.start_with?("require_relative")
          process_require_relative(line, path)
        elsif line.start_with?("require")
          process_require(line)
        else
          line
        end
      end.join
    end

    def process_require_relative(line, path)
      required_file = line.split.last[1..-2]
      required_path = "#{File.expand_path(required_file, File.dirname(path))}.rb"

      return "" if already_required.include?(required_path)

      already_required << required_path
      process_file(required_path)
    end

    def process_require(line)
      required_file = line.split.last[1..-2]
      required_path = Gem.find_files(required_file).first

      return "" if required_path.nil? || already_required.include?(required_path)

      already_required << required_path
      process_file(required_path)
    end
  end
end
