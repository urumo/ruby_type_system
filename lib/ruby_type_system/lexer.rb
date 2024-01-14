# frozen_string_literal: true

module RubyTypeSystem
  class LexerError < StandardError; end

  class Lexer
    attr_reader :code, :tokens

    KEYWORDS = %w[BEGIN END alias and begin break case class def defined? do else elsif end ensure false for if in
                  module next nil not or redo rescue retry return self super then true undef unless until when
                  while yield].freeze
  end

  def initialize(code)
    @code = code
    @tokens = []
  end

  def tokenize
    code.chomp!

    i = 0
    while i < code.size; end
  end
end
