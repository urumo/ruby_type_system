# frozen_string_literal: true

module RubyTypeSystem
  class TokenError < StandardError; end

  KEYWORDS = %w[BEGIN END alias and begin break case class def defined? do else elsif end ensure false for if in
                module next nil not or redo rescue retry return self super then true undef unless until when
                while yield].freeze

  TYPES = %w[Numeric Integer Float String Hash Array Set Symbol Range Regexp Proc IO File Time
             TrueClass FalseClass NilClass Object Class Module Method Struct Expression].freeze

  Token = Struct.new(:type, :literal, :line, :column) do
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
    IDENTIFIER = :identifier
    COLON = :colon
    NUMBER = :number
    EQUAL = :equal
    MATCH = :match
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
    EOF = :eof
  end
  module OldTokenType
    EOF = :EOF
    IDENTIFIER = :IDENTIFIER
    NUMERIC = :NUMERIC
    NUMBER = :NUMBER
    INTEGER = :INTEGER
    FLOAT = :FLOAT
    STRING = :STRING
    HEREDOC = :HEREDOC
    COMMENT = :COMMENT
    HASH = :HASH
    ARRAY = :ARRAY
    SET = :SET
    PROC = :PROC
    IO = :IO
    FILE = :FILE
    TIME = :TIME
    TRUECLASS = :TRUE_CLASS
    FALSECLASS = :FALSE_CLASS
    NILCLASS = :NIL_CLASS
    OBJECT = :OBJECT
    METHOD = :METHOD
    STRUCT = :STRUCT
    EXPRESSION = :EXPRESSION
    ASSIGN = :ASSIGN
    PLUS = :PLUS
    MINUS = :MINUS
    MULTIPLY = :MULTIPLY
    DIVIDE = :DIVIDE
    LPAREN = :LPAREN
    RPAREN = :RPAREN
    LBRACE = :LBRACE
    RBRACE = :RBRACE
    COMMA = :COMMA
    DOT = :DOT
    SEMICOLON = :SEMICOLON
    COLON = :COLON
    DOUBLE_COLON = :DOUBLE_COLON
    PIPE = :PIPE
    AMPERSAND = :AMPERSAND
    BANG = :BANG
    QUESTION = :QUESTION
    AT = :AT
    ATAT = :ATAT
    DOLLAR = :DOLLAR
    DOUBLE_QUOTE = :DOUBLE_QUOTE
    SINGLE_QUOTE = :SINGLE_QUOTE
    BACKSLASH = :BACKSLASH
    PERCENT = :PERCENT
    CARET = :CARET
    TILDE = :TILDE
    LT = :LT
    GT = :GT
    LEQ = :LEQ
    GEQ = :GEQ
    EQ = :EQ
    NEQ = :NEQ
    AND = :AND
    OR = :OR
    NOT = :NOT
    IF = :IF
    ELSE = :ELSE
    ELSIF = :ELSIF
    UNLESS = :UNLESS
    WHILE = :WHILE
    UNTIL = :UNTIL
    FOR = :FOR
    IN = :IN
    DO = :DO
    THEN = :THEN
    YIELD = :YIELD
    RETURN = :RETURN
    DEF = :DEF
    CLASS = :CLASS
    MODULE = :MODULE
    SELF = :SELF
    NIL = :NIL
    TRUE = :TRUE
    FALSE = :FALSE
    SUPER = :SUPER
    BEGIN_T = :BEGIN_T
    BEGIN_CAPITAL = :BEGIN_CAPITAL
    RESCUE = :RESCUE
    ENSURE = :ENSURE
    END_T = :END_T
    END_CAPITAL = :END_CAPITAL
    ALIAS = :ALIAS
    DEFINED = :DEFINED
    UNDEF = :UNDEF
    CASE = :CASE
    WHEN = :WHEN
    NEXT = :NEXT
    BREAK = :BREAK
    REDO = :REDO
    RETRY = :RETRY
    LBRACKET = :LBRACKET
    RBRACKET = :RBRACKET
    RANGE = :RANGE
    RANGE_EXCLUSIVE = :RANGE_EXCLUSIVE
    LSHIFT = :LSHIFT
    RSHIFT = :RSHIFT
    BIT_AND = :BIT_AND
    BIT_OR = :BIT_OR
    BIT_XOR = :BIT_XOR
    BIT_NOT = :BIT_NOT
    LOGICAL_AND = :LOGICAL_AND
    LOGICAL_OR = :LOGICAL_OR
    LOGICAL_NOT = :LOGICAL_NOT
    EQUAL = :EQUAL
    NOT_EQUAL = :NOT_EQUAL
    LESS_THAN = :LESS_THAN
    LESS_THAN_EQUAL = :LESS_THAN_EQUAL
    GREATER_THAN = :GREATER_THAN
    GREATER_THAN_EQUAL = :GREATER_THAN_EQUAL
    MATCH = :MATCH
    NOT_MATCH = :NOT_MATCH
    CASE_EQUAL = :CASE_EQUAL
    PLUS_EQUAL = :PLUS_EQUAL
    MINUS_EQUAL = :MINUS_EQUAL
    MULTIPLY_EQUAL = :MULTIPLY_EQUAL
    DIVIDE_EQUAL = :DIVIDE_EQUAL
    MOD_EQUAL = :MOD_EQUAL
    EXPONENTIAL_EQUAL = :EXPONENTIAL_EQUAL
    BIT_AND_EQUAL = :BIT_AND_EQUAL
    BIT_OR_EQUAL = :BIT_OR_EQUAL
    BIT_XOR_EQUAL = :BIT_XOR_EQUAL
    LSHIFT_EQUAL = :LSHIFT_EQUAL
    RSHIFT_EQUAL = :RSHIFT_EQUAL
    AND_EQUAL = :AND_EQUAL
    OR_EQUAL = :OR_EQUAL
    RANGE_INCLUSIVE = :RANGE_INCLUSIVE
    UNARY_PLUS = :UNARY_PLUS
    UNARY_MINUS = :UNARY_MINUS
    UNARY_NOT = :UNARY_NOT
    UNARY_BIT_NOT = :UNARY_BIT_NOT
    HEREDOC_BEGIN = :HEREDOC_BEGIN
    HEREDOC_END = :HEREDOC_END
    SYMBOL = :SYMBOL
    TYPE_SPEC = :TYPE_SPEC
    REGEXP = :REGEXP
    GLOBAL_VAR = :GLOBAL_VAR
    INSTANCE_VAR = :INSTANCE_VAR
    CLASS_VAR = :CLASS_VAR
    BACKTICK = :BACKTICK
    ELLIPSIS = :ELLIPSIS
    SAFE_NAVIGATOR = :SAFE_NAVIGATOR
    HASH_ROCKET = :HASH_ROCKET
    LAMBDA = :LAMBDA
    SPLAT = :SPLAT
    DOUBLE_SPLAT = :DOUBLE_SPLAT
    TRIPLE_EQUAL = :TRIPLE_EQUAL
    OPTIONAL_PARAMS = :OPTIONAL_PARAMS
    KEYWORD_PARAMS = :KEYWORD_PARAMS
    BLOCK_BEGIN = :BLOCK_BEGIN
    BLOCK_END = :BLOCK_END
    IN_PATTERN = :IN_PATTERN
    PATTERN_BEGIN = :PATTERN_BEGIN
    PATTERN_END = :PATTERN_END
    ONE_LINE_METHOD = :ONE_LINE_METHOD
    NEW_LINE = :NEW_LINE
    SPACE = :SPACE
  end

  class << self
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
