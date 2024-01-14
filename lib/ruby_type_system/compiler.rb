# frozen_string_literal: true

module RubyTypeSystem

  class CompilerError < StandardError; end
  class Compiler
    attr_reader :code, :output

    def initialize(code)
      @variables = {}
      @code = code
      @output = ""
    end

    def compile
      parse
      compile_code
      write_file
    end

    private

    def parse
      code.lines.each do |line|
        next unless line.include?(":") && line.include?("=")

        name, rest = line.split(":").map(&:strip)
        type, value = rest.split("=").map(&:strip)
        @variables[name] = { type:, value: }
      end
    end

    def compile_code
      @variables.each do |name, data|
        @output += "#{name}= #{data[:value]}\n"
        @output += "raise TypeError, \"Expected type #{data[:type]}, got #{name}.class\" unless " \
                   "#{name}.is_a?(#{data[:type]})\n"
      end
    end

    def write_file
      FileUtils.mkdir_p("dist")
      File.write("dist/compiled.rb", @output)
    end
  end
end
