# encoding: UTF-8
class String
  def camelcase = self.split(/_/).map(&:capitalize).join
  def camelcase_unless_caps = (self.camelcase if self =~ /[a-z]/)
  def underscore = (self.gsub(/([A-Z])/, '_\1').gsub(/^_/,'').downcase)
  def underscore_unless_caps = (self.underscore unless self =~ /^[A-Z]+$/)
end
