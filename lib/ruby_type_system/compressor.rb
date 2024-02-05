# frozen_string_literal: true

module RubyTypeSystem
  class Compressor
    attr_reader :file_path, :already_required

    def initialize(file_path)
      raise "File does not exist" unless File.exist?(file_path)

      @file_path = file_path
      @already_required = []
    end

    def compress
      program_begin = <<~RUBY
        #!/usr/bin/env ruby

        # frozen_string_literal: true
      RUBY
      compressed_code = program_begin + process_file(file_path)
      File.write("dist/compressed.rb", compressed_code) # for debugging
      compressed_code
    end

    private

    def process_file(path)
      return "" if path.include?("/generators/")
      return "" if %w[.so .o .dll .dylib .bundle].include?(File.extname(path))
      return "" unless File.exist?(path)

      if File.directory?(path)
        return Dir.entries(path).reject { |f| File.directory? f }.map do |file|
          process_file(File.join(path, file))
        end.join
      end

      code = File.read(path).force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace, replace: "")

      begin
        RubyVM::InstructionSequence.compile(code)
      rescue SyntaxError
        return ""
      end

      code.lines.map do |line|
        if line.start_with?(/^\s*#/)
          ""
        elsif line.start_with?("require_relative")
          process_require_relative(line, path)
        elsif line.start_with?("require")
          process_require(line)
        elsif ["#!/usr/bin/env ruby", "# frozen_string_literal: true"].include?(line.strip)
          ""
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

      gem_require = Gem.find_files(required_file)
      required_path = gem_require.first

      return line if required_path.nil?
      return "" if already_required.include?(required_path)

      already_required << required_path
      process_file(required_path)
    end
  end
end
