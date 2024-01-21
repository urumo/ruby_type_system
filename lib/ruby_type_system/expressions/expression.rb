# frozen_string_literal: true

module RubyTypeSystem
  module Expressions
    class Expression
      attr_reader :token

      def initialize(token)
        @token = token
      end

      def literal = token.literal

      def to_s
        raise NotImplementedError
      end
    end
  end
end
