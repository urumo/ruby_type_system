# frozen_string_literal: true

require "json"

RSpec.describe RubyTypeSystem do
  let(:test_path) { File.join(File.dirname(__FILE__), "examples") }
  let(:tests) { Dir.entries(test_path).reject { |f| File.directory? f } }

  it "has a version number" do
    expect(RubyTypeSystem::VERSION).not_to be nil
  end

  describe "lexer" do
    let(:result_path) { File.join(File.dirname(__FILE__), "lexer/results") }
    it "has tests to pass" do
      expect(tests).not_to be_empty
    end

    it "passes tests from examples folder" do
      tests.each do |test_case|
        code = File.read(File.join(test_path, test_case))
        lexer = RubyTypeSystem.tokenize(code)
        json = JSON.parse(File.read(File.join(result_path, "#{test_case}.json")), symbolize_names: true)
        tokens_array = lexer.tokens.size.times.map { lexer.tokens.deq.to_hash }
        expect(tokens_array).to eq(json)
      end
    end
  end

  describe "parser" do
    let(:result_path) { File.join(File.dirname(__FILE__), "parser/results") }
    it "has tests to pass" do
      expect(tests).not_to be_empty
    end

    it "passes tests from examples folder" do
      tests.each do |test_case|
        code = File.read(File.join(test_path, test_case))
        RubyTypeSystem.parse(code)
        # pp parser
        # pp parser.ast
        # json = JSON.parse(File.read(File.join(result_path, "#{test_case}.json")), symbolize_names: true)
        # expect(parser.ast.to_hash).to eq(json)
      end
    end
  end
end
