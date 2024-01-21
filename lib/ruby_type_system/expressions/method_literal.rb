# frozen_string_literal: true

module RubyTypeSystem
  module Expressions
    class MethodLiteral < Expression
      attr_reader :type, :name, :arguments, :body

      def initialize(token, type, name, arguments, body)
        super(token)
        @type = type
        @name = name
        @arguments = arguments
        @body = body
      end
    end
  end
end
