# frozen_string_literal: true

RSpec.describe RubyTypeSystem do
  it "has a version number" do
    expect(RubyTypeSystem::VERSION).not_to be nil
  end

  it "does lex" do
    code = <<~CODE
      class Klass
        def initialize(foo: Integer, bar: String)
          @foo = foo
          @bar = bar
        end
        def greet: Integer
          foo.times do
            puts bar
          end

          foo
        end
      end
      foo: Integer = 1
      bar: String = "hello"
      foo_bar: Klass = Klass.new(foo, bar)
      greeted_n_times: Integer = foo_bar.greet
    CODE

    lexer = RubyTypeSystem.tokenize(code)
    pp lexer.tokens
  end
end
