# frozen_string_literal: true

require "json"

RSpec.describe RubyTypeSystem do

  it "has a version number" do
    expect(RubyTypeSystem::VERSION).not_to be nil
  end

  describe "lexer" do
    let(:test_path) { File.join(File.dirname(__FILE__), "lexer/examples") }
    let(:result_path) { File.join(File.dirname(__FILE__), "lexer/results") }
    let(:tests) { Dir.entries(test_path).reject { |f| File.directory? f } }
    it "has tests to pass" do
      expect(tests).not_to be_empty
    end

    it "passes tests from examples folder" do
      tests.each do |test_case|
        code = File.read(File.join(test_path, test_case))
        lexer = RubyTypeSystem.tokenize(code)
        json = JSON.parse(File.read(File.join(result_path, "#{test_case}.json")), symbolize_names: true)
        expect(lexer.tokens.map(&:to_hash)).to eq(json)
      end
    end
  end

  describe "parser" do
    let(:test_path) { File.join(File.dirname(__FILE__), "parser/examples") }
    let(:result_path) { File.join(File.dirname(__FILE__), "parser/results") }
    let(:tests) { Dir.entries(test_path).reject { |f| File.directory? f } }
    it "has tests to pass" do
      expect(tests).not_to be_empty
    end

    it "passes tests from examples folder" do
      tests.each do |test_case|
        code = File.read(File.join(test_path, test_case))
        lexer = RubyTypeSystem.tokenize(code)
        parser = RubyTypeSystem.parse(lexer.tokens)
        json = JSON.parse(File.read(File.join(result_path, "#{test_case}.json")), symbolize_names: true)
        expect(parser.ast.to_hash).to eq(json)
      end
    end
  end
end
