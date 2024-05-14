#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'app-config'
require 'app-logger'
# require_relative 'http-request'

App::Config.init approot: Pathname(__dir__).expand_path
App::Logger.new

if ARGV[0] =~ /^--?h/
  puts <<~EHELP
  Отвечает на все запросы по HTTP структурой {"responce":{"message":"pong"}}
  Если задан параметр - ищёт файл с кодом в папке responders и отвечает
  форматом и методом:
  out_fmt, answer = Responder.responce(body, in_fmt, out_fmt)
  где body - исходный расшифрованный запрос
  остальные параметры являются необязательными рекомендациями и равны :plain

EHELP
  exit
end
x = ARGV[0] || 'default'
# puts "Загружаю ответчик responders/#{ x }.rb"
# require_relative "responders/#{ x }.rb"

# use Rack::ShowExceptions
# use Rack::Reloader
body = ''
Log.info "Соломенный бычок зашёл."
app = Proc.new do |env|
# require 'pry-byebug'
# binding.pry
  # request = HTTPRequest.new Rack::Request.new( env )
  Log.add Logger::UNKNOWN, <<~EINPUT
  #{ env.inspect() }
  body: #{ env["rack.input"].read }
EINPUT
  #{ request.request_method } #{ request.fullpath }
  #{ env.select{|k,v| k =~ /^[A-Z_]+$/ }.inspect }
  #{ request.payload.inspect }
  # puts env.inspect
  # in_fmt = Glutton.determine_format env['CONTENT_TYPE']
  # out_fmt = (in_fmt == :urlenc) ? :xml : in_fmt
  # body = Glutton.process_x in_fmt, body
  # answer = Responder.answer request
  # answer
  # ['200', {'Content-Type' => Glutton.format2header( out_fmt ) }, answer ]
  # puts "Принял в #{ env['CONTENT_TYPE'] }, отвечаю #{ answer }\n-----\n\n"
  ['200', {'Content-Type' => "text/plain" }, "Хорошо" ]
end

Rack::Handler::Thin.run app, Port: (Cfg.http.port || 4000), Host: (Cfg.http.host || '0.0.0.0')
Log.info "Соломенный бычок вышел."
