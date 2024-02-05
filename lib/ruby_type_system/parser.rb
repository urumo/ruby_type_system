# frozen_string_literal: true

module RubyTypeSystem
  module AstTypes
    PROGRAM = :program
    EXPRESSION = :expression
    STATEMENT = :statement
  end

  class ParserError < StandardError; end

  class Parser
    attr_reader :tokens, :ast, :current_token, :lexer

    def initialize(lexer)
      super()
      @tokens = lexer.tokens
      @tokens = Array.new(tokens.size, nil).zip(tokens.size.times.map { tokens.deq })
      @tokens.pop
      # @ast = Ast.new(::RubyTypeSystem::AstTypes::PROGRAM, nil, [])
    end

    def next_token
      tokens.shift
    end
  end
end
