require_relative '../http-request'

module Responder
  @root = Pathname( __FILE__ ).dirname.parent.expand_path.freeze

  module_function
  def answer( request ) # <= HTTPRequest; => [ code, { headers }, [ body ] ]
    case request
    in request_method: 'GET'
      [ 200, {}, [ 'not implemented' ] ]
    in request_method: 'POST'
      [ 201, {}, [ 'not implemented' ] ]
    else
      [ 404, {}, [ 'not found' ] ]
  end
end
