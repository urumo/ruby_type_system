# encoding: UTF-8
require 'json'
require 'nori'
require 'msgpack'
require 'iconv'
require_relative 'input_data_error'
require_relative 'extended_hash'

# 1. Опознать кодировку, перевести в utf-8 при необходимости
# 2. Опознать формат, перевести в hash
module Glutton
  
  def Glutton.process_x( fmt, data )
    Glutton.send "process_#{ fmt }", data
  end

  def Glutton.process_json( data )
    JSON.parse( data )
  rescue JSON::ParserError => e
    raise InputFormatError.new(e.message)
  end

  def Glutton.process_xml( data )
    # Защита от кулхацкеров
    if data =~ /<!DOCTYPE[^>]+>|xsi:schemaLocation\s*=|<xs:schema|xmlns:xs=/
      raise InputDataHack.new('Invalid data provided')
    end
    # На всякий случай удаляем заголовок, могут быть глюки у Nori
    Nori.new.parse data.gsub(/^<\?xml[^>]+>\n*/i,'')
  end

  def Glutton.process_msgpack( data )
    MessagePack.unpack( data )
  end

  def Glutton.process_urlenc( data )
    Hash[ *URI::decode( data ).split(/[&=]/) ]
    rescue
      Hash[ *data.split('&').collect{|i| i.split('=',2).map{|j| j.empty? ? nil : j }} ] 
  end

  def Glutton.process_plain( data )
    data.force_encoding 'UTF-8'
  end

  def Glutton.determine_input_enc( content_type )
    e = content_type ? ( content_type.split( /charset=/ )[1] || 'utf-8' ) : 'utf-8'
    Encoding.find e
    return e
  end

  def Glutton.determine_output_enc( env )
    e = env.key?('HTTP_ACCEPT_CHARSET') ? ( env['HTTP_ACCEPT_CHARSET'].split(',')[0] || 'utf-8' ) : 'utf-8'
    Encoding.find e
    return e
  end

  def Glutton.determine_format( hdr )
    puts "got hdr #{ hdr }"
    case hdr
      when /(application|text)\/xml/ then :xml
      when /(application|text)\/json/ then :json
      when /application\/((x-)?msgpack|octet-stream)/ then :msgpack
      when /x-www-form-urlencoded/ then :urlenc
      else
        :plain
    end
  end

  def Glutton.format2header( fmt )
    { xml: 'text/xml', json: 'application/json', msgpack: 'application/x-msgpack', plain: 'text/plain' }[fmt]
  end

  def Glutton.read_and_decode( io, enc )
    # binding.pry
    body = io.read
    raise DataError.new if body.nil? || body.length < 10
    # body передадим на GW, если что
    body = body.force_encoding('utf-8')
    body.gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '') if enc =~ /^UTF|^SCSU|^BOCU-1|^GB-18030/i
    io.rewind
    return body
  end

  def Glutton.cleaning(data)
    if kx = data.recursive_key?(/[^a-zA-Z0-9_\.]/)
      raise InputDataHack.new("Found invalid key(s)"){ kx.inspect }
    end
    k = data.keys & %w[request Request]
    raise DataError.new if k.empty?
    data = data[k.first]
    %w[id, Id, ID].each{ |x| k.delete x }
    data
  end

end
