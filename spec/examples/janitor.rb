# encoding: UTF-8
# Чтение настроек, создание необходимых папок, создаёт $log
require 'fileutils'
require 'pathname'
require 'yaml'

module Janitor
  # Добавляет глобальные переменные для доступа к общим ресурсам
  # Логирование: $log.info{"Вывод в лог"}
  # Лог по умолчанию: STDERR
  # Доступ к настройкам: $cfg['name']
  # Доступ к базе: $db
  def Janitor.load_setup
    print "Janitor is loading settings..."
    $project_root = Pathname( __FILE__ ).dirname.expand_path.to_s.freeze
    $runmode = ( ENV['PROXY_RUN_ENVIRONMENT'] || :development ).to_sym
    $cfg = ( YAML.load_file( "#{ $project_root.to_s }/settings.yml" )[$runmode].merge(
                YAML.load_file("#{ $project_root .to_s }/info/about.yml")['public'] ) ).freeze
    $log =
      case $cfg[:log]
      when 'syslog'
        require 'syslog/logger'
        Syslog::Logger.new "service.#{ $cfg['name'] }", Syslog::LOG_PID | Syslog::LOG_DAEMON | Syslog::LOG_LOCAL0
      when 'stdout'
        require 'logger'
        Logger.new STDOUT
      when nil, 'stderr'
        require 'logger'
        Logger.new STDERR
      else
        require 'logger'
        Logger.new File.open($cfg[:log], 'w')
      end

    $log.info { "#{ $cfg['name'] } #{$cfg[:ver]}, pid: #{ Process.pid } loaded" }
    $log.info { 'loaded' }
    print " загрузил.\n\n"
  end

  def reconfigure
    $log.info{ 'reloading settings'}
    Janitor.load_setup
  end

  def end_of_service = $log.warn{"ligh off"}

end

Janitor.load_setup
