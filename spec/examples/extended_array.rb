# encoding: UTF-8
class Array
  def deep_transform!(&block)
    self.map do |e|
      case e
        when Array then e.deep_transform!(&block)
        when Hash then e.deep_transform_values!(&block)
        else yield(e)
      end
    end
  end
end
