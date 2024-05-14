require 'json'

module Responder
  @root = Pathname( __FILE__ ).dirname.parent.expand_path.freeze

  module_function
  def answer(request)
    if request.post? && request.path =~ /(setWebhook|sendMessage)$/
      [ 200, { 'Content-Type' => 'application/json' }, [{ ok: true, result: true, description: 'ok' }.to_json] ]
    else
      [ 502, { 'Content-Type' => 'application/json' }, [{ ok: false, result: false, description: 'Webhook was not set' }.to_json] ]
    end
  end
end
