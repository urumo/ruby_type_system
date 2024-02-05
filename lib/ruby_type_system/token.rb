# frozen_string_literal: true
#
module RubyTypeSystem
  class TokenError < StandardError; end

  KEYWORDS = %w[BEGIN END alias and begin break case class def defined? do else elsif end ensure false for if in
                module next nil not or redo rescue retry return self super then true undef unless until when
                while yield].freeze

  # BUILTINS = %w[require require_relative load puts print p raise fail abort exit include extend prepend].freeze

  TYPES = %w[Numeric Integer Float String Hash Array Set Symbol Range Regexp Proc IO File Time
             TrueClass FalseClass NilClass Object Class Module Method Struct Expression].freeze

  class Token
    attr_reader :type, :literal, :line, :column

    def initialize(type, literal, line, column)
      @type = type
      @literal = literal
      @line = line
      @column = column
    end

    def to_a
      [type, literal]
    end

    def to_hash
      {
        type: type.to_s,
        literal: literal,
        line: line,
        column: column
      }
    end
  end

  module TokenType
    STRING = :string
    LITERAL = :literal
    IDENTIFIER = :identifier
    COLON = :colon
    SYMBOL = :symbol
    NUMBER = :number
    EQUAL = :equal
    MATCH = :match
    NOT_MATCH = :not_match
    HEREDOC = :heredoc
    PERCENT_I = :symbol_array
    PERCENT_Q = :non_interpolated_string
    PERCENT_R = :regexp
    PERCENT_S = :string_symbol
    PERCENT_W = :string_array
    PERCENT_X = :shell_command
    PERCENT_CAIPTAL_I = :interpolated_symbol_array
    PERCENT_CAPITAL_Q = :interpolated_string
    PERCENT_CAPITAL_W = :interpolated_string_array
    ASSIGN = :assign
    PLUS_EQUAL = :plus_equal
    PLUS = :plus
    MINUS_EQUAL = :minus_equal
    MINUS = :minus
    MULTIPLY_EQUAL = :multiply_equal
    MULTIPLY = :multiply_equal
    DIVIDE_EQUAL = :divide_equal
    DIVIDE = :divide
    BACKSLASH = :backslash
    LPAREN = :lparen
    RPAREN = :rparen
    LBRACE = :lbrace
    RBRACE = :rbrace
    LBRACKET = :lbracket
    RBRACKET = :rbracket
    COMMA = :comma
    ELLIPSIS = :elipsis
    RANGE = :range
    DOT = :dot
    SEMICOLON = :semicolon
    OR = :or
    OR_ASSIGN = :or_assign
    PIPE = :pipe
    AND = :and
    AMPERSAND = :ampersand
    BANG = :bang
    NOT_EQUAL = :not_equal
    QUESTION = :question
    AT = :at
    ATAT = :atat
    DOLLAR = :dollar
    PERCENT = :percent
    CARET = :caret
    BITWISE_XOR_ASSIGN = :bitwise_xor_assign
    LESS_THAN_OR_EQUAL = :less_than_or_equal
    LESS_THAN = :less_than
    LEFT_SHIFT = :left_shift
    LEFT_SHIFT_ASSIGN = :left_shift_assign
    POWER_ASSIGN = :power_assign
    POWER = :power
    GREATER_THAN = :greater_than
    GREATER_THAN_OR_EQUAL = :greater_than_or_equal
    BITWISE_AND_ASSIGN = :bitwise_and_assign
    AND_ASSIGN = :and_assign
    RIGHT_SHIFT = :right_shift
    RIGHT_SHIFT_ASSIGN = :right_shift_assign
    MODULO_ASSIGN = :modulo_assign
    BITWISE_OR_ASSIGN = :bitwise_or_assign
    EOF = :eof
  end

  # module Builtins
  #   REQUIRE = :require
  #   REQUIRE_RELATIVE = :require_relative
  #   LOAD = :load
  #   PUTS = :puts
  #   PRINT = :print
  #   P = :p
  #   RAISE = :raise
  #   FAIL = :fail
  #   ABORT = :abort
  #   EXIT = :exit
  #   INCLUDE = :include
  #   EXTEND = :extend
  #   PREPEND = :prepend
  # end

  module Keywords
    BEGIN_CAPITAL = :begin_capital
    END_CAPITAL = :end_capital
    ALIAS = :alias
    AND = :and
    BEGIN_T = :begin
    BREAK = :break
    CASE = :case
    CLASS = :class
    DEF = :def
    DEFINED = :defined?
    DO = :do
    ELSE = :else
    ELSIF = :elsif
    END_T = :end
    ENSURE = :ensure
    FALSE = false
    FOR = :for
    IF = :if
    IN = :in
    MODULE = :module
    NEXT = :next
    NIL = :nil
    NOT = :not
    OR = :or
    REDO = :redo
    RESCUE = :rescue
    RETRY = :retry
    RETURN = :return
    SELF = :self
    SUPER = :super
    THEN = :then
    TRUE = true
    UNDEF = :undef
    UNLESS = :unless
    UNTIL = :until
    WHEN = :when
    WHILE = :while
    YIELD = :yield
  end

  class << self
    def check_type_or_keyword(token)
      return keyword_token(token) if KEYWORDS.include?(token)

      # return builtin_token(token) if BUILTINS.include?(token)
      ::RubyTypeSystem::TokenType::IDENTIFIER
    end

    def builtin_token(token)
      case token
      when BUILTINS[0]
        ::RubyTypeSystem::Builtins::REQUIRE
      when BUILTINS[1]
        ::RubyTypeSystem::Builtins::REQUIRE_RELATIVE
      when BUILTINS[2]
        ::RubyTypeSystem::Builtins::LOAD
      when BUILTINS[3]
        ::RubyTypeSystem::Builtins::PUTS
      when BUILTINS[4]
        ::RubyTypeSystem::Builtins::PRINT
      when BUILTINS[5]
        ::RubyTypeSystem::Builtins::P
      when BUILTINS[6]
        ::RubyTypeSystem::Builtins::RAISE
      when BUILTINS[7]
        ::RubyTypeSystem::Builtins::FAIL
      when BUILTINS[8]
        ::RubyTypeSystem::Builtins::ABORT
      when BUILTINS[9]
        ::RubyTypeSystem::Builtins::EXIT
      when BUILTINS[10]
        ::RubyTypeSystem::Builtins::INCLUDE
      when BUILTINS[11]
        ::RubyTypeSystem::Builtins::EXTEND
      when BUILTINS[12]
        ::RubyTypeSystem::Builtins::PREPEND
      else
        raise LexerError, "Unknown builtin #{token}"
      end
    end

    def keyword_token(token)
      case token
      when KEYWORDS[0]
        ::RubyTypeSystem::Keywords::BEGIN_CAPITAL
      when KEYWORDS[1]
        ::RubyTypeSystem::Keywords::END_CAPITAL
      when KEYWORDS[2]
        ::RubyTypeSystem::Keywords::ALIAS
      when KEYWORDS[3]
        ::RubyTypeSystem::Keywords::AND
      when KEYWORDS[4]
        ::RubyTypeSystem::Keywords::BEGIN_T
      when KEYWORDS[5]
        ::RubyTypeSystem::Keywords::BREAK
      when KEYWORDS[6]
        ::RubyTypeSystem::Keywords::CASE
      when KEYWORDS[7]
        ::RubyTypeSystem::Keywords::CLASS
      when KEYWORDS[8]
        ::RubyTypeSystem::Keywords::DEF
      when KEYWORDS[9]
        ::RubyTypeSystem::Keywords::DEFINED
      when KEYWORDS[10]
        ::RubyTypeSystem::Keywords::DO
      when KEYWORDS[11]
        ::RubyTypeSystem::Keywords::ELSE
      when KEYWORDS[12]
        ::RubyTypeSystem::Keywords::ELSIF
      when KEYWORDS[13]
        ::RubyTypeSystem::Keywords::END_T
      when KEYWORDS[14]
        ::RubyTypeSystem::Keywords::ENSURE
      when KEYWORDS[15]
        ::RubyTypeSystem::Keywords::FALSE
      when KEYWORDS[16]
        ::RubyTypeSystem::Keywords::FOR
      when KEYWORDS[17]
        ::RubyTypeSystem::Keywords::IF
      when KEYWORDS[18]
        ::RubyTypeSystem::Keywords::IN
      when KEYWORDS[19]
        ::RubyTypeSystem::Keywords::MODULE
      when KEYWORDS[20]
        ::RubyTypeSystem::Keywords::NEXT
      when KEYWORDS[21]
        ::RubyTypeSystem::Keywords::NIL
      when KEYWORDS[22]
        ::RubyTypeSystem::Keywords::NOT
      when KEYWORDS[23]
        ::RubyTypeSystem::Keywords::OR
      when KEYWORDS[24]
        ::RubyTypeSystem::Keywords::REDO
      when KEYWORDS[25]
        ::RubyTypeSystem::Keywords::RESCUE
      when KEYWORDS[26]
        ::RubyTypeSystem::Keywords::RETRY
      when KEYWORDS[27]
        ::RubyTypeSystem::Keywords::RETURN
      when KEYWORDS[28]
        ::RubyTypeSystem::Keywords::SELF
      when KEYWORDS[29]
        ::RubyTypeSystem::Keywords::SUPER
      when KEYWORDS[30]
        ::RubyTypeSystem::Keywords::THEN
      when KEYWORDS[31]
        ::RubyTypeSystem::Keywords::TRUE
      when KEYWORDS[32]
        ::RubyTypeSystem::Keywords::UNDEF
      when KEYWORDS[33]
        ::RubyTypeSystem::Keywords::UNLESS
      when KEYWORDS[34]
        ::RubyTypeSystem::Keywords::UNTIL
      when KEYWORDS[35]
        ::RubyTypeSystem::Keywords::WHEN
      when KEYWORDS[36]
        ::RubyTypeSystem::Keywords::WHILE
      when KEYWORDS[37]
        ::RubyTypeSystem::Keywords::YIELD
      else
        raise LexerError, "Unknown keyword #{token}"
      end
    end
  end
end
