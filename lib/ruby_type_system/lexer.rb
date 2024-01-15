# frozen_string_literal: true

module RubyTypeSystem
  class LexerError < StandardError; end

  class Lexer
    attr_reader :code, :tokens

    def initialize(code)
      @code = code.chomp
      @tokens = []
    end

    def tokenize
      i = 0
      line = 1
      inside_string = false
      string_single_quote = false
      while i < code.size
        char = code[i]
        if inside_string
          start = i
          quote = string_single_quote ? "'" : '"'
          i += 1 while code[i] != quote || (code[i] == quote && code[i - 1] == "\\")
          tokens << Token.new(::RubyTypeSystem::TokenType::STRING, code[start...i], line, start)
          inside_string = false
          i += 1
        end
        case char
        when "\n"
          line += 1
          i += 1
        when /[[:alpha:]_]/
          start = i
          i += 1 while code[i] =~ /[[:word:]]/
          token = code[start...i]
          tokens << Token.new(::RubyTypeSystem::TokenType::IDENTIFIER, token, line, start) if token.size.positive?
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
          # tokens << Token.new(::RubyTypeSystem::TokenType::DOUBLE_QUOTE, char, line, i)
          inside_string = true
          i += 1
        when "'"
          inside_string = true
          string_single_quote = true
          # tokens << Token.new(::RubyTypeSystem::TokenType::SINGLE_QUOTE, char, line, i)
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
        #   tokens << Token.new(::RubyTypeSystem::TokenType::HASH, char, line, i)
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
  end
end
