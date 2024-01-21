# frozen_string_literal: true

module RubyTypeSystem
  class ParserError < StandardError; end

  class Parser
    attr_reader :tokens, :ast, :current_token

    def initialize(lexer)
      @tokens = lexer.tokens
      @current_token = tokens.shift
      @ast = Ast.new(:program, nil, [])
    end

    def parse
      while current_token.type != ::RubyTypeSystem::TokenType::EOF
        case current_token.type
        when ::RubyTypeSystem::TokenType::IDENTIFIER
          ast.add_child(parse_identifier)
        when ::RubyTypeSystem::TokenType::NUMBER
          ast.add_child(parse_number)
        else
          raise ParserError, "Unexpected token #{current_token.type}"
        end
      end
    end

    private

    def parse_identifier
      node = Ast.new(:identifier, current_token, [])
      consume(::RubyTypeSystem::TokenType::IDENTIFIER)
      node
    end

    def parse_number
      node = Ast.new(:number, current_token, [])
      consume(::RubyTypeSystem::TokenType::NUMBER)
      node
    end

    def consume(expected_type)
      unless current_token.type == expected_type
        raise ParserError, "Expected #{expected_type} but got #{current_token.type}"
      end

      @current_token = tokens.shift
    end
  end
end
