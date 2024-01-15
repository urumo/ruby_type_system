# frozen_string_literal: true

module RubyTypeSystem
  class AstError < StandardError; end

  class Ast
    attr_reader :type, :token, :children

    def initialize(type, token, children)
      @type = type
      @token = token
      @children = children
    end

    def add_child(node)
      @children << node
    end
  end
end
