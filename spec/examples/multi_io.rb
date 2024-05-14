class Tee
  def initialize(*targets) = (@targets = targets)
  def write(*args) = @targets.each{|t| t.write args}
  def close = @targets.each(&:close)
end
