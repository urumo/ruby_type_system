require 'securerandom'
require 'erb'

module Responder
  @answer = YAML.load ERB.new( File.read "#{ $project_root }/responders/acquira-dead.yml" ).result
  def Responder.answer(body, in_fmt = :plain, out_fmt = :plain)
    return [ @answer['answer']['code'], @answer['answer']['headers'], @answer['answer']['body'] ]
  end
end