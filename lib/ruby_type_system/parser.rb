# frozen_string_literal: true

module RubyTypeSystem
  class ParserError < StandardError; end

  class Parser
    attr_reader :tokens, :ast

    def initialize(tokens)
      @tokens = tokens
      @ast = []
    end

    def parse
      nil
    end
  end
end
