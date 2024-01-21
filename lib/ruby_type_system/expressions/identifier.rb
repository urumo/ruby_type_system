# frozen_string_literal: true

module RubyTypeSystem
  module Expressions
    class Identifier < Expression
      attr_reader :type, :value

      def initialize(token, type, value)
        super(token)
        @type = type
        @value = value
      end

      def to_s
        "#{literal} = #{value}
raise TypeError, \"Expected #{type}, got \#{#{literal}.class}\" unless #{literal}.is_a?(#{type})
"
      end
    end
  end
end
