module Responder
  def Responder.answer(body, in_fmt = :plain, out_fmt = :plain)
    [ 200,
      { 'Content-Type' => 'text/plain;charset=UTF-8' },
      ['OK'] ]
  end
end
