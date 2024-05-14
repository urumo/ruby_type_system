# encoding: UTF-8
require 'gyoku'
require 'iconv'
require_relative 'extended_string'

class Hash
  def deep_clone = (Marshal.load Marshal.dump self)

  def to_format(t = :xml, enc = 'utf-8')
    %i{xml json msgpack}.include?(t) ? send("encode_to_#{ t }", enc ) : nil
  end
  def encode_to_json(enc = 'utf-8') = self.to_json.encode(enc) # здесь какая-то загадка

  def encode_to_xml(enc = 'utf-8')
    <<~EENCXML
    <?xml version="1.0" encoding="#{ enc }"?>
    #{ Gyoku.xml(self.deep_clone.deep_transform_values!{|v| v.nil? ? '' : v }, { key_converter: :none, unwrap: true, element_form_default: true }) }

    EENCXML
  end
  def encode_to_msgpack(enc = 'utf-8') = self.to_msgpack

  def recursive_key?(key)
    if key.is_a?(Regexp) then
      kx = []
      each do |k, v|
        if v.is_a?(Hash)
          kx += v.recursive_key?(key) || []
        elsif k.is_a?(Array)
        else
          kx << k if k =~ key
        end
      end
      return kx.empty? ? nil : kx
    else
      each{|k, v| return { k => v } if k == key || ( v.is_a?(Hash) && v.recursive_key?(key) ) }
    end
    return nil
  end
  def recursive_val(key)
    self.each do |k, v|
      return v if k == key || ( v.is_a?(Hash) && (v = v.recursive_val(key)) )
    end
    return nil
  end
  # https://github.com/rails/rails/blob/55f9b8129a50206513264824abb44088230793c2/activesupport/lib/active_support/core_ext/hash/keys.rb
  # Returns a new hash with all keys converted using the +block+ operation.
  #  hash = { name: 'Rob', age: '28' }
  #  hash.transform_keys { |key| key.to_s.upcase } # => {"NAME"=>"Rob", "AGE"=>"28"}
  # If you do not provide a +block+, it will return an Enumerator
  # for chaining with other methods:
  # hash.transform_keys.with_index { |k, i| [k, i].join } # => {"name0"=>"Rob", "age1"=>"28"}
  def transform_keys
    return enum_for(:transform_keys) { size } unless block_given?
    result = {}
    each_key do |key|
      result[yield(key)] = self[key]
    end
    result
  end
  # Destructively converts all keys using the +block+ operations.
  # Same as +transform_keys+ but modifies +self+.
  def transform_keys!
    return enum_for(:transform_keys!) { size } unless block_given?
    keys.each do |key|
      self[yield(key)] = delete(key)
    end
    self
  end
  # Returns a new hash with all keys converted to strings.
  #   hash = { name: 'Rob', age: '28' }
  #   hash.stringify_keys
  #   # => {"name"=>"Rob", "age"=>"28"}
  def stringify_keys
    transform_keys(&:to_s)
  end
  # Destructively converts all keys to strings. Same as
  # +stringify_keys+, but modifies +self+.
  def stringify_keys!
    transform_keys!(&:to_s)
  end
  # Returns a new hash with all keys converted to symbols, as long as
  # they respond to +to_sym+.
  #   hash = { 'name' => 'Rob', 'age' => '28' }
  #   hash.symbolize_keys
  #   # => {:name=>"Rob", :age=>"28"}
  def symbolize_keys = (transform_keys { |key| key.to_sym rescue key })

  alias_method :to_options,  :symbolize_keys
  # Destructively converts all keys to symbols, as long as they respond
  # to +to_sym+. Same as +symbolize_keys+, but modifies +self+.
  def symbolize_keys! = (transform_keys! { |key| key.to_sym rescue key })

  alias_method :to_options!, :symbolize_keys!
  # Validates all keys in a hash match <tt>*valid_keys</tt>, raising
  # +ArgumentError+ on a mismatch.
  # Note that keys are treated differently than HashWithIndifferentAccess,
  # meaning that string and symbol keys will not match.
  #   { name: 'Rob', years: '28' }.assert_valid_keys(:name, :age) # => raises "ArgumentError: Unknown key: :years. Valid keys are: :name, :age"
  #   { name: 'Rob', age: '28' }.assert_valid_keys('name', 'age') # => raises "ArgumentError: Unknown key: :name. Valid keys are: 'name', 'age'"
  #   { name: 'Rob', age: '28' }.assert_valid_keys(:name, :age)   # => passes, raises nothing
  def assert_valid_keys(*valid_keys)
    valid_keys.flatten!
    each_key do |k|
      unless valid_keys.include?(k)
        raise ArgumentError.new("Unknown key: #{k.inspect}. Valid keys are: #{valid_keys.map(&:inspect).join(', ')}")
      end
    end
  end
  # Returns a new hash with all keys converted by the block operation.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  #  hash = { person: { name: 'Rob', age: '28' } }
  #  hash.deep_transform_keys{ |key| key.to_s.upcase }
  #  # => {"PERSON"=>{"NAME"=>"Rob", "AGE"=>"28"}}
  def deep_transform_keys(&block)
    _deep_transform_keys_in_object(self, &block)
  end
  # Destructively converts all keys by using the block operation.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  def deep_transform_keys!(&block)
    _deep_transform_keys_in_object!(self, &block)
  end
  # Returns a new hash with all keys converted to strings.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  #   hash = { person: { name: 'Rob', age: '28' } }
  #   hash.deep_stringify_keys
  #   # => {"person"=>{"name"=>"Rob", "age"=>"28"}}
  def deep_stringify_keys
    deep_transform_keys(&:to_s)
  end
  # Destructively converts all keys to strings.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  def deep_stringify_keys!
    deep_transform_keys!(&:to_s)
  end

  # Returns a new hash with all keys converted to symbols, as long as
  # they respond to +to_sym+. This includes the keys from the root hash
  # and from all nested hashes and arrays.
  #   hash = { 'person' => { 'name' => 'Rob', 'age' => '28' } }
  #   hash.deep_symbolize_keys
  #   # => {:person=>{:name=>"Rob", :age=>"28"}}
  def deep_symbolize_keys
    deep_transform_keys { |key| key.to_sym rescue key }
  end
  # Destructively converts all keys to symbols, as long as they respond
  # to +to_sym+. This includes the keys from the root hash and from all
  # nested hashes and arrays.
  def deep_symbolize_keys!
    deep_transform_keys! { |key| key.to_sym rescue key }
  end

  def deep_normalize_keys
    deep_transform_keys { |key| key.underscore_unless_caps.to_sym rescue key }
  end
  def deep_normalize_keys!
    deep_transform_keys! { |key| key.underscore_unless_caps.to_sym rescue key }
  end
  def deep_camelize_keys
    deep_transform_keys { |key| key.camelcase_unless_caps.to_sym rescue key }
  end

  def deep_transform_values!(&block)
    self.each do |k, v|
      case v
        when Array  then self[k] = v.deep_transform!(&block)
        when Hash   then self[k] = v.deep_transform_values!(&block)
        else self[k] = yield(v)
      end
    end
  end
  def deep_merge!(other)
    self.merge!(other){|k, x, y| mp k, x, y}
  end
  private
    def mp(key, v1, v2)
      if v1.is_a?(Hash) && v2.is_a?(Hash)
        v1.merge!(v2){|k,x,y| mp k, x, y }
      elsif v1.is_a?(Hash)
        v1
      else
        v2
      end
    end

    # support methods for deep transforming nested hashes and arrays
    def _deep_transform_keys_in_object(object, &block)
      case object
      when Hash
        object.each_with_object({}) do |(key, value), result|
          result[yield(key)] = _deep_transform_keys_in_object(value, &block)
        end
      when Array
        object.map { |e| _deep_transform_keys_in_object(e, &block) }
      else
        object
      end
    end

    def _deep_transform_keys_in_object!(object, &block)
      case object
      when Hash
        object.keys.each do |key|
          value = object.delete(key)
          object[yield(key)] = _deep_transform_keys_in_object!(value, &block)
        end
        object
      when Array
        object.map! { |e| _deep_transform_keys_in_object!(e, &block) }
      else
        object
      end
    end
end
