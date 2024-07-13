# encoding: UTF-8
class EError < StandardError
  attr_reader :visa_code, :correlation_id, :errmsg
  def initialize( msg = 'Errors happens.',
      correlation_id = nil,
      visa_code = 5,
      errmsg = 'E'
    )
    @visa_code = visa_code
    @correlation_id = correlation_id
    @logmsg ||= nil
    @errmsg = errmsg
    Steward.log.warn{ "#{ self.class }#{ ": '#{ @logmsg }" if @logmsg && ! @logmsg.empty? } VISA code: #{ visa_code }. CorrelationID: #{ correlation_id }. #{ self.message }#{ ' ' + yield if block_given? }" }
    super msg
  end
end

class DataError < EError
  def initialize(msg = 'Invalid data supplied.', correlation_id = nil, visa_code = 6, errmsg = 'E_FORMAT_ERROR')
    super
  end
end

class InputFormatError < EError
  def initialize(msg = 'Input format is not recognized.', correlation_id = nil, visa_code = 6, errmsg = 'E_FORMAT_UNKNOWN')
    super
  end
end

class InputEncodingError < EError
  def initialize(msg = 'Input encoding is not recognized.', correlation_id = nil, visa_code = 6, errmsg = 'E_ENCODING')
    super
  end
end

class InputDataHack < EError
  def initialize(msg = "Invalid input data.", correlation_id = nil, visa_code = 6, errmsg = 'E_UNKNOWN0' )
    @logmsg = "На нас напали! correlation_id: #{ correlation_id }. #{ msg }"
    super
  end
end

class UnknownError < EError
  def initialize(msg = 'Unknown error.', correlation_id = nil, visa_code = 5, errmsg = 'E_UNKNOWN')
    @logmsg = Thread.current.backtrace.join("\n")
    super
  end
end

class InvalidRoute < EError
  def initialize(msg = "I've lost the route!", correlation_id = nil, visa_code = -6, errmsg = 'E_NO_ROUTE')
    super
  end
end

class GetAnswerLater < EError
  def initialize(msg = "Timeout reading from service.", correlation_id = nil, visa_code = 9, errmsg = 'OK_PROCESSING')
    super
  end
end

class InternalError < EError
  def initialize(msg = "Something strange happened.", correlation_id = nil, visa_code = 5, errmsg = 'E_FATAL')
    @logmsg = self.message + "\n" + Thread.current.backtrace.join("\n")
    super
  end
end

class AccessDenied < EError
  def initialize(msg = "Anonymous access denied.", correlation_id = nil, visa_code = -17, errmsg = 'E_ACCESS_DENIED')
    super
  end
end

class EGWTimeout < EError
  def initialize(msg = "Timeout reading from GW.", correlation_id = nil, visa_code = -4, errmsg = 'E_GW_TIMEOUT' )
    super
  end
end
