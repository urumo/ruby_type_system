# Обработать-распарсить тело, положить в payload
require_relative 'glutton'

class HTTPRequest
  attr_reader :params, :payload, :output_enc, :input_enc, :content_type
  def initialize( rack_request )
    @request = rack_request
    @content_type = Glutton.determine_format( @request.content_type )
    unpack_body
  end

  def params          = @request.params
  def request_method  = @request.request_method
  def path            = @request.path
  def fullpath        = @request.fullpath
  def post?           = (@request.request_method == 'POST')
  def get?            = (@request.request_method == 'GET')

  private
  def unpack_body
    @request.body.rewind
    @payload = Glutton.process_x(
        @content_type,
        @request.body.read.to_s )
  end

  def deconstruct_keys( ks )
    {
      request: @request,
      request_method: request_method(),
      path: path(),
      fullpath: fullpath(),
      params: params(),
      output_enc: @output_enc || 'utf-8',
      input_enc: @input_enc || 'utf-8',
      content_type: @content_type,
      paylod: @payload || unpack_body(),
      is_post: post?(),
      is_get: get?()
    }
  end

  def to_hash = deconstruct_keys()

end
