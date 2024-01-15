# frozen_string_literal: true

require "json"

RSpec.describe RubyTypeSystem do
  describe "lexer" do
    let(:test_path) { File.join(File.dirname(__FILE__), "lexer/examples") }
    let(:result_path) { File.join(File.dirname(__FILE__), "lexer/results") }
    let(:tests) { Dir.entries(test_path).reject { |f| File.directory? f } }
    it "has tests to pass" do
      pp tests
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

  it "has a version number" do
    expect(RubyTypeSystem::VERSION).not_to be nil
  end
end
