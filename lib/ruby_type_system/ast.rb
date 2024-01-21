# frozen_string_literal: true

module RubyTypeSystem
  class AstError < StandardError; end

  class Ast
    attr_reader :type, :token, :statements

    def initialize(type, token, statements)
      @type = type
      @token = token
      @statements = statements
    end
  end
end
