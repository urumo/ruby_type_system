# frozen_string_literal: true

require_relative 'expressions/identifier'

module RubyTypeSystem
  module AstTypes
    PROGRAM = :program
    CLASS = :class
    MODULE = :module
    METHOD = :method
    ARGUMENT = :argument
    KEYWORD_ARGUMENT = :keyword_argument
    BLOCK = :block
    CONSTANT = :constant
    LOCAL_VARIABLE = :local_variable
    INSTANCE_VARIABLE = :instance_variable
    CLASS_VARIABLE = :class_variable
    GLOBAL_VARIABLE = :global_variable
    ARRAY = :array
    HASH = :hash
    SET = :set
    RANGE = :range
    REGEXP = :regexp
    STRING = :string
    INTEGER = :integer
    FLOAT = :float
    SYMBOL = :symbol
    BOOLEAN = :boolean
    NIL = :nil
    SELF = :self
    TRUE = :true
    FALSE = :false
    EXPRESSION = :expression
  end
  class ParserError < StandardError; end

  class Parser
    attr_reader :tokens, :ast, :current_token

    def initialize(lexer)
      @tokens = lexer.tokens
      @current_token = tokens.shift
      @ast = Ast.new(::RubyTypeSystem::AstTypes::PROGRAM, nil, [])
    end

    def parse
      while current_token.type != ::RubyTypeSystem::TokenType::EOF
      end
    end

    private

  end
end

