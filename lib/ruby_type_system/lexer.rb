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
      line = 1
      while i < code.size
        char = code[i]
        case char
        when "\n"
          line += 1
          i += 1
        when /[[:alpha:]_]/
          start = i
          i += 1 while code[i] =~ /[[:word:]]/
          token = code[start...i]
          type = check_type_or_keyword(token)
          tokens << Token.new(type, token, line, start)
        when ':'
          tokens << Token.new(::RubyTypeSystem::TokenType::COLON, char, line, i)
          i += 1
        when /[[:digit:]]/
          start = i
          i += 1 while code[i] =~ /[[:digit:]]/
          tokens << Token.new(::RubyTypeSystem::TokenType::INTEGER, code[start..i].strip, line, start)
        when '='
          tokens << Token.new(::RubyTypeSystem::TokenType::ASSIGN, char, line, i)
          i += 1
        else
          i += 1
        end

        tokens << Token.new(::RubyTypeSystem::TokenType::EOF, nil, 1, i) if i == code.size
      end
    end

    private

    def check_type_or_keyword(token)
      return keyword_token(token) if KEYWORDS.include?(token)
      return ::RubyTypeSystem::TokenType::TYPE_SPEC if TYPES.include?(token)

      ::RubyTypeSystem::TokenType::IDENTIFIER
    end

    def keyword_token(token)
      case token
      when KEYWORDS[0]
        ::RubyTypeSystem::TokenType::BEGIN_CAPITAL
      when KEYWORDS[1]
        ::RubyTypeSystem::TokenType::END_CAPITAL
      when KEYWORDS[2]
        ::RubyTypeSystem::TokenType::ALIAS
      when KEYWORDS[3]
        ::RubyTypeSystem::TokenType::AND
      when KEYWORDS[4]
        ::RubyTypeSystem::TokenType::BEGIN_T
      when KEYWORDS[5]
        ::RubyTypeSystem::TokenType::BREAK
      when KEYWORDS[6]
        ::RubyTypeSystem::TokenType::CASE
      when KEYWORDS[7]
        ::RubyTypeSystem::TokenType::CLASS
      when KEYWORDS[8]
        ::RubyTypeSystem::TokenType::DEF
      when KEYWORDS[9]
        ::RubyTypeSystem::TokenType::DEFINED
      when KEYWORDS[10]
        ::RubyTypeSystem::TokenType::DO
      when KEYWORDS[11]
        ::RubyTypeSystem::TokenType::ELSE
      when KEYWORDS[12]
        ::RubyTypeSystem::TokenType::ELSIF
      when KEYWORDS[13]
        ::RubyTypeSystem::TokenType::END_T
      when KEYWORDS[14]
        ::RubyTypeSystem::TokenType::ENSURE
      when KEYWORDS[15]
        ::RubyTypeSystem::TokenType::FALSE
      when KEYWORDS[16]
        ::RubyTypeSystem::TokenType::FOR
      when KEYWORDS[17]
        ::RubyTypeSystem::TokenType::IF
      when KEYWORDS[18]
        ::RubyTypeSystem::TokenType::IN
      when KEYWORDS[19]
        ::RubyTypeSystem::TokenType::MODULE
      when KEYWORDS[20]
        ::RubyTypeSystem::TokenType::NEXT
      when KEYWORDS[21]
        ::RubyTypeSystem::TokenType::NIL
      when KEYWORDS[22]
        ::RubyTypeSystem::TokenType::NOT
      when KEYWORDS[23]
        ::RubyTypeSystem::TokenType::OR
      when KEYWORDS[24]
        ::RubyTypeSystem::TokenType::REDO
      when KEYWORDS[25]
        ::RubyTypeSystem::TokenType::RESCUE
      when KEYWORDS[26]
        ::RubyTypeSystem::TokenType::RETRY
      when KEYWORDS[27]
        ::RubyTypeSystem::TokenType::RETURN
      when KEYWORDS[28]
        ::RubyTypeSystem::TokenType::SELF
      when KEYWORDS[29]
        ::RubyTypeSystem::TokenType::SUPER
      when KEYWORDS[30]
        ::RubyTypeSystem::TokenType::THEN
      when KEYWORDS[31]
        ::RubyTypeSystem::TokenType::TRUE
      when KEYWORDS[32]
        ::RubyTypeSystem::TokenType::UNDEF
      when KEYWORDS[33]
        ::RubyTypeSystem::TokenType::UNLESS
      when KEYWORDS[34]
        ::RubyTypeSystem::TokenType::UNTIL
      when KEYWORDS[35]
        ::RubyTypeSystem::TokenType::WHEN
      when KEYWORDS[36]
        ::RubyTypeSystem::TokenType::WHILE
      when KEYWORDS[37]
        ::RubyTypeSystem::TokenType::YIELD
      else
        raise LexerError, "Unknown keyword #{token}"
      end
    end
  end
end
