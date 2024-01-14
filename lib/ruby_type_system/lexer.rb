# frozen_string_literal: true

module RubyTypeSystem
  class LexerError < StandardError; end

  class Lexer
    attr_reader :code, :tokens

    KEYWORDS = %w[BEGIN END alias and begin break case class def defined? do else elsif end ensure false for if in
                  module next nil not or redo rescue retry return self super then true undef unless until when
                  while yield].freeze

    TYPES = %w[Numeric Integer Float String Hash Array Set Symbol Range Regexp Proc IO File Time
               TrueClass FalseClass NilClass Object Class Module Method Struct Expression].freeze

    def initialize(code)
      @code = code.chomp
      @tokens = []
    end

    def tokenize
      i = 0
      while i < code.size
        char = code[i]
        case char
        when /[[:alpha:]_]/
          start = i
          i += 1 while code[i] =~ /[[:word:]]/
          token = code[start...i]
          type = if KEYWORDS.include?(token) || TYPES.include?(token)
                   token.upcase.to_sym
                 else
                   ::RubyTypeSystem::TokenType::IDENTIFIER
                 end
          tokens << Token.new(type, token, 1, start)
        when ':'
          tokens << Token.new(::RubyTypeSystem::TokenType::COLON, char, 1, i)
          i += 1
        when /[[:digit:]]/
          start = i
          i += 1 while code[i] =~ /[[:digit:]]/
          tokens << Token.new(::RubyTypeSystem::TokenType::INTEGER, code[start..i].strip, 1, start)
        when '='
          tokens << Token.new(::RubyTypeSystem::TokenType::ASSIGN, char, 1, i)
          i += 1
        else
          i += 1
        end

        tokens << Token.new(::RubyTypeSystem::TokenType::EOF, nil, 1, i) if i == code.size
      end
    end
  end
end
