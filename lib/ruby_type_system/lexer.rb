# frozen_string_literal: true

module RubyTypeSystem
  class LexerError < StandardError; end

  class Lexer
    attr_reader :code, :tokens

    def initialize(code)
      @code = code.chomp
      @tokens = Queue.new
    end

    def tokenize
      i = 0
      line = 1
      opening_delimiters = "!@#$%^&*_+-=:;'\",./?\\<([{"
      closing_delimiters = "!@#$%^&*_+-=:;'\",./?\\>)]}"
      array_types = %w[i q r s w x I Q W]
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
          tokens << Token.new(::RubyTypeSystem.check_type_or_keyword(token), token, line, start) if token.size.positive?
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
          tokens << Token.new(::RubyTypeSystem::TokenType::NUMBER, code[start...i].strip, line, start)
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
        when '"', "'"
          i = tokenize_string(i, char, line)
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
          elsif code[i + 1] == "*" && code[i + 2] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::POWER_ASSIGN, "**=", line, i)
            i += 2
          elsif code[i + 1] == "*"
            tokens << Token.new(::RubyTypeSystem::TokenType::POWER, "**", line, i)
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
          i += 1 while code[i] != "\n" && i <= code.size
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
          if code[i + 1] == "|" && code[i + 2] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::OR_ASSIGN, "||=", line, i)
            i += 2
          elsif code[i + 1] == "|"
            tokens << Token.new(::RubyTypeSystem::TokenType::OR, "||", line, i)
            i += 1
          elsif code[i + 1] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::BITWISE_OR_ASSIGN, "|=", line, i)
            i += 1
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::PIPE, char, line, i)
          end
          i += 1
        when "&"
          if code[i + 1] == "&" && code[i + 2] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::AND_ASSIGN, "&&=", line, i)
            i += 2
          elsif code[i + 1] == "&"
            tokens << Token.new(::RubyTypeSystem::TokenType::AND, "&&", line, i)
            i += 1
          elsif code[i + 1] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::BITWISE_AND_ASSIGN, "&=", line, i)
            i += 1
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::AMPERSAND, char, line, i)
          end
          i += 1
        when "!"
          if code[i + 1] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::NOT_EQUAL, "!=", line, i)
            i += 1
          elsif code[i + 1] == "~"
            tokens << Token.new(::RubyTypeSystem::TokenType::NOT_MATCH, "!~", line, i)
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
          if array_types.include?(code[i + 1]) && opening_delimiters.include?(code[i + 2])
            opening_delimiter_index = opening_delimiters.index(code[i + 2])
            opening_delimiter = code[i + 2]
            closing_delimiter = closing_delimiters[opening_delimiter_index]
            literal = "%#{code[i + 1]}#{opening_delimiter}"
            tokens << typed_array_literal(code[i + 1], literal, line, i)
            i += literal.size
            start = i
            i += 1 while code[i] != closing_delimiter
            code[start...i].split.each do |word|
              tokens << Token.new(::RubyTypeSystem::TokenType::LITERAL, word, line, start)
            end

            # tokens << Token.new(::RubyTypeSystem::TokenType::LITERAL, code[start...i], line, start)
          elsif code[i + 1] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::MODULO_ASSIGN, "%=", line, i)
            i += 2
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::PERCENT, char, line, i)
            i += 1
          end
        when "^"
          if code[i + 1] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::BITWISE_XOR_ASSIGN, "^=", line, i)
            i += 1
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::CARET, char, line, i)
          end
          i += 1
        when "<"
          if code[i + 1] == "<" && code[i + 2] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::LEFT_SHIFT_ASSIGN, "<<=", line, i)
            i += 2
          elsif code[i + 1] == "<" && code[i + 2] == "~"
            tokens << Token.new(::RubyTypeSystem::TokenType::HEREDOC, "<<~", line, i)
            i += 2
          elsif code[i + 1] == "<"
            tokens << Token.new(::RubyTypeSystem::TokenType::LEFT_SHIFT, "<<", line, i)
            i += 1
          elsif code[i + 1] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::LESS_THAN_OR_EQUAL, "<=", line, i)
            i += 1
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::LESS_THAN, char, line, i)
          end
          i += 1
        when ">"
          if code[i + 1] == ">" && code[i + 2] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::RIGHT_SHIFT_ASSIGN, ">>=", line, i)
            i += 2
          elsif code[i + 1] == ">"
            tokens << Token.new(::RubyTypeSystem::TokenType::RIGHT_SHIFT, ">>", line, i)
            i += 1
          elsif code[i + 1] == "="
            tokens << Token.new(::RubyTypeSystem::TokenType::GREATER_THAN_OR_EQUAL, ">=", line, i)
            i += 1
          else
            tokens << Token.new(::RubyTypeSystem::TokenType::GREATER_THAN, char, line, i)
          end
          i += 1
        when " ", "\t"
          i += 1
        else
          pp char
          raise LexerError, "Unknown character #{char}"
        end

        tokens << Token.new(::RubyTypeSystem::TokenType::EOF, nil, 1, i) if i == code.size
      end
    end

    private

    def typed_array_literal(type, literal, line, start)
      case type
      when "i"
        Token.new(::RubyTypeSystem::TokenType::PERCENT_I, literal, line, start)
      when "q"
        Token.new(::RubyTypeSystem::TokenType::PERCENT_Q, literal, line, start)
      when "r"
        Token.new(::RubyTypeSystem::TokenType::PERCENT_R, literal, line, start)
      when "s"
        Token.new(::RubyTypeSystem::TokenType::PERCENT_S, literal, line, start)
      when "w"
        Token.new(::RubyTypeSystem::TokenType::PERCENT_W, literal, line, start)
      when "x"
        Token.new(::RubyTypeSystem::TokenType::PERCENT_X, literal, line, start)
      when "I"
        Token.new(::RubyTypeSystem::TokenType::PERCENT_CAPITAL_I, literal, line, start)
      when "Q"
        Token.new(::RubyTypeSystem::TokenType::PERCENT_CAPITAL_Q, literal, line, start)
      when "W"
        Token.new(::RubyTypeSystem::TokenType::PERCENT_CAPITAL_W, literal, line, start)
      else
        raise LexerError, "Unknown array type #{type}"
      end
    end

    def tokenize_string(index, quote, line)
      start = index
      index += 1
      index += 1 while code[index] != quote || (code[index] == quote && code[index - 1] == "\\")
      index += 1
      tokens << Token.new(::RubyTypeSystem::TokenType::STRING, code[start...index], line, start)
      index
    end
  end
end
