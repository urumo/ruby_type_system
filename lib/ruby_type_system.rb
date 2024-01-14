# frozen_string_literal: true

require_relative "ruby_type_system/version"
require_relative "ruby_type_system/compressor"
require_relative "ruby_type_system/lexer"
require_relative "ruby_type_system/parser"
require_relative "ruby_type_system/compiler"

module RubyTypeSystem
  class Error < StandardError; end

  class << self
    def compress(path)
      Compressor.new(path).compress
    end

    def parse(code)
      Parser.new(tokenize(code)).parse
    end

    def tokenize(code)
      Lexer.new(code).tokenize
    end

    def compile(code)
      Compiler.new(parse(code)).compile
    end

    def process(path)
      compile(compress(path))
    end
  end
end
