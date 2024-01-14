# frozen_string_literal: true

module RubyTypeSystem
  class ParserError < StandardError; end

  class Parser
  end
end

# def function(a: String, b: String, c: Hash[String, String])
#   c.each do |k, v|
#     puts "#{a} | #{k} #{v} | #{b}"
#   end
# end
# this function should be compiled to:
# def function(a, b, c)
#  raise TypeError, "Expected type String, got a.class" unless a.is_a?(String)
# raise TypeError, "Expected type String, got b.class" unless b.is_a?(String)
# c.each do |k, v|
#  raise TypeError, "Expected type String, got k.class" unless k.is_a?(String)
# raise TypeError, "Expected type String, got v.class" unless v.is_a?(String)
# puts "#{a} | #{k} #{v} | #{b}"
# end
# end

# type A = String | Integer
# type Bool = TrueClass | FalseClass
# type C = Hash[A, Bool]
# some_error_hash: C = {"a" => true, 2 => 3} #=> TypeError
# some_hash: C = {"a" => true, "b" => false, 3 => true} #=> {"a" => true, "b" => false, 3 => true}
