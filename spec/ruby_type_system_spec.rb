# frozen_string_literal: true

require "json"

RSpec.describe RubyTypeSystem do
  it "has a version number" do
    expect(RubyTypeSystem::VERSION).not_to be nil
  end

  it "does lex" do
    code = '
      class Klass
        def initialize(foo: Integer, bar: String)
          @@foo_bar = 1
          @foo = foo
          @bar = bar
        end
        def greet: Float
          foo.times do |i|
            puts "#{bar} #{i}"
          end

          12.2
        end
      end
      foo: Integer = 1
      bar: String = "hel\"l\"o"
      foo_bar: Klass = Klass.new(foo, bar)
      greeted_n_times: Float = foo_bar.greet
    '

    lexer = RubyTypeSystem.tokenize(code)
    pp lexer.tokens.map(&:to_hash)
  end
end
