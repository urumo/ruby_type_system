# frozen_string_literal: true

require "json"

require_relative "ruby_type_system/version"
require_relative "ruby_type_system/token"
require_relative "ruby_type_system/compressor"
require_relative "ruby_type_system/lexer"
require_relative "ruby_type_system/ast"
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
      lexer = Lexer.new(code)
      lexer.tokenize
      lexer
    end

    def compile(code)
      Compiler.new(parse(code)).compile
    end

    def process(path)
      compile(compress(path))
    end
  end
end
