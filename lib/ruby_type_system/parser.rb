# frozen_string_literal: true

require_relative "expressions/identifier"

module RubyTypeSystem
  module AstTypes
    PROGRAM = :program
    EXPRESSION = :expression
    STATEMENT = :statement
  end

  class ParserError < StandardError; end

  class Parser
    attr_reader :tokens, :ast, :current_token

    def initialize(lexer)
      @tokens = lexer.tokens
      @current_token = tokens.deq
      @ast = Ast.new(::RubyTypeSystem::AstTypes::PROGRAM, nil, [])
    end

    def parse; end
  end
end
