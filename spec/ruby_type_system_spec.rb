# frozen_string_literal: true

RSpec.describe RubyTypeSystem do
  it "has a version number" do
    expect(RubyTypeSystem::VERSION).not_to be nil
  end

  it "does lex" do
    code = <<~CODE
      foo: Integer = 1
      bar: String = "hello"
      foo_bar: Array[Integer] = [1, 2, 3]
    CODE

    lexer = RubyTypeSystem.tokenize(code)
    pp lexer.tokens
  end
end
