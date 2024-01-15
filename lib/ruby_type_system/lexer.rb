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
        # if inside_string
        #   start = i
        #   i += 1 while code[i] != '"' || (code[i] == '"' && code[i - 1] == "\\")
        #   tokens << Token.new(::RubyTypeSystem::TokenType::STRING, code[start...i], line, start)
        #   inside_string = false
        #   i += 1
        # end
        case char
        when "\n"
          line += 1
          i += 1
        when /[[:alpha:]_]/
          start = i
          i += 1 while code[i] =~ /[[:word:]]/
          token = code[start...i]
          tokens << Token.new(::RubyTypeSystem::TokenType::IDENTIFIER, token, line, start)
        when ":"
          tokens << Token.new(::RubyTypeSystem::TokenType::COLON, char, line, i)
          i += 1
        when /[[:digit:]]/
          start = i
          i += 1 while code[i] =~ /[[:digit:]]/
          if code[i] == "." && code[i + 1] =~ /[[:digit:]]/
            i += 1
            i += 1 while code[i] =~ /[[:digit:]]/
          end
          tokens << Token.new(::RubyTypeSystem::TokenType::NUMBER, code[start..i].strip, line, start)
        when "="
          if code[i + 1] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::EQUAL, "==", line, i)
            i += 1
          elsif code[i + 1] == "~"
            tokens << Token.new(::RubyTypeSystem::TokenType::MATCH, "=~", line, i)
            i += 1
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::ASSIGN, char, line, i)
          end
          i += 1
        when '"'
          tokens << Token.new(::RubyTypeSystem::TokenType::DOUBLE_QUOTE, char, line, i)
          # inside_string = true
          i += 1
        when "'"
          tokens << Token.new(::RubyTypeSystem::TokenType::SINGLE_QUOTE, char, line, i)
          i += 1
        when "+"
          if code[i + 1] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::PLUS_EQUAL, "+=", line, i)
            i += 1
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::PLUS, char, line, i)
          end
          i += 1
        when "-"
          if code[i + 1] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::MINUS_EQUAL, "-=", line, i)
            i += 1
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::MINUS, char, line, i)
          end
          i += 1
        when "*"
          if code[i + 1] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::MULTIPLY_EQUAL, "*=", line, i)
            i += 1
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::MULTIPLY, char, line, i)
          end
          i += 1
        when "/"
          if code[i + 1] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::DIVIDE_EQUAL, "/=", line, i)
            i += 1
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::DIVIDE, char, line, i)
          end
          i += 1
        when "#"
          tokens << Token.new(::RubyTypeSystem::TokenType::HASH, char, line, i)
          i += 1
        when "\\"
          tokens << Token.new(::RubyTypeSystem::TokenType::BACKSLASH, char, line, i)
          i += 1
        when "("
          tokens << Token.new(::RubyTypeSystem::TokenType::LPAREN, char, line, i)
          i += 1
        when ")"
          tokens << Token.new(::RubyTypeSystem::TokenType::RPAREN, char, line, i)
          i += 1
        when "{"
          tokens << Token.new(::RubyTypeSystem::TokenType::LBRACE, char, line, i)
          i += 1
        when "}"
          tokens << Token.new(::RubyTypeSystem::TokenType::RBRACE, char, line, i)
          i += 1
        when "["
          tokens << Token.new(::RubyTypeSystem::TokenType::LBRACKET, char, line, i)
          i += 1
        when "]"
          tokens << Token.new(::RubyTypeSystem::TokenType::RBRACKET, char, line, i)
          i += 1
        when ","
          tokens << Token.new(::RubyTypeSystem::TokenType::COMMA, char, line, i)
          i += 1
        when "."
          if code[i + 1] == "." && code[i + 2] == "."
            tokens << Token.new(::RubyTypeSystem::TokenType::ELLIPSIS, "...", line, i)
            i += 2
          elsif code[i + 1] == "."
            tokens << Token.new(::RubyTypeSystem::TokenType::RANGE, "..", line, i)
            i += 1
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::DOT, char, line, i)
          end
          i += 1
        when ";"
          tokens << Token.new(::RubyTypeSystem::TokenType::SEMICOLON, char, line, i)
          i += 1
        when "|"
          if code[i + 1] == "|"
            tokens << Token.new(::RubyTypeSystem::TokenType::OR, "||", line, i)
            i += 1
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::PIPE, char, line, i)
          end
          i += 1
        when "&"
          if code[i + 1] == "&"
            tokens << Token.new(::RubyTypeSystem::TokenType::AND, "&&", line, i)
            i += 1
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::AMPERSAND, char, line, i)
          end
          i += 1
        when "!"
          if code[i + 1] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::NOT_EQUAL, "!=", line, i)
            i += 1
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::BANG, char, line, i)
          end
          i += 1
        when "?"
          tokens << Token.new(::RubyTypeSystem::TokenType::QUESTION, char, line, i)
          i += 1
        when "@"
          if code[i + 1] == "@"
            tokens << Token.new(::RubyTypeSystem::TokenType::ATAT, "@@", line, i)
            i += 1
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::AT, "@", line, i)
          end
          i += 1
        when "$"
          tokens << Token.new(::RubyTypeSystem::TokenType::DOLLAR, char, line, i)
          i += 1
        when "%"
          tokens << Token.new(::RubyTypeSystem::TokenType::PERCENT, char, line, i)
          i += 1
        when "^"
          tokens << Token.new(::RubyTypeSystem::TokenType::CARET, char, line, i)
          i += 1
        when " "
          i += 1
        else
          raise LexerError, "Unknown character #{char}"
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
