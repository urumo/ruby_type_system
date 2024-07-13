#!/usr/bin/env ruby
=begin
Порядок действий:

01 Зайти по ssh на источник
02 Забрать список контейнеров и отфильтровать те, где есть session_id и они есть в списке сопоставления
03 НЦ, для каждого sessionId
05 Скопировать папку хрома на назначение
06 Запустить контейнер на назначении, подставив скопированную папку из 05, с той же версией браузера
07 Записать на STDOUT новый session_id и md5 хэш для GGR
09 ~~Остановить контейнер источника~~
10 КЦ

Чтобы подключиться к докерному unixsocket на источнике

а) соединяем и пробрасываем порт: удалённый localhost:2375 <-> локальный localhost:8100
б) удалённо запускаем nc 2375 > fifo > docker.sock > fifo > nc 2375
в) отдаём команды докеру на локальный tcp порт 8100

Докер на назначении слушает на порту №2375
=end

raise unless RUBY_VERSION =~ /^3\./
ENV['OPENSSL_CONF'] = "#{ __dir__ }/add_legacy.cnf"

if ARGV.count != 1
  puts <<~HELP

    Копирует докеры с вебдрайвером с одного хоста на другой.
    Запуск:
          ./cp_host.rb customerIds.csv > newconfig.csv
    Где:
      customerIds.csv — файл соответствий customer_id;session_id;username;src_ip;username;dstIP
      newconfig.csv   — результат копирования: customerId;newSessionId;md5hash=ip+session
    Также см. cfg.yml

    Подсказка:
      Можно копировать контейнеры из одного источника на разные назначения.

  HELP
  exit 1
end

require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'json'
require 'logger'
require 'ed25519'
require 'bcrypt_pbkdf'
require 'net/http'
require 'digest'
require 'fileutils'
require 'base64'
require_relative './util.rb'

init_cfg()
sessions = {}
File.readlines(ARGV.first).each do |line|
      next if line =~ /^\s*$/
      cuid, sid, usrc, srcip, udst, dstip = line.chomp.gsub(/;$/, "").split(/\s*;\s*/)
      k = [srcip, dstip, usrc, udst]
      data = { customerId: cuid, sessionId: sid }
      sessions[k] ||= []
      sessions[k] << data
    end
FileUtils.rm_f "/tmp/copy_data.log"

# по хостам
sessions.each do |ips, idlist|
  src_ip, dstIP, usrc, udst = ips
  $cfg[:log].info "#{ src_ip } -> #{ dstIP }"
  [src_ip, dstIP].each{|ip| raise_exit( get_ssh_redirections(), "Не доступен #{ ip }" ) unless check_connection( ip ) }
  $cfg[:log].info "  Пингуются и входится."
  # подготовка
  sshSrcURI = "#{ usrc }@#{ src_ip }"
  sshDstURI = "#{ udst }@#{ dstIP }"
  redir_src_all = spawn("ssh -f -n -A -L#{$cfg[:src][:docker]}:#{$cfg[:src][:sock]} -L#{$cfg[:src][:selenix]}:localhost:4444 -N #{ sshSrcURI }")
  redir_dst_all = spawn("ssh -f -n -A -L#{$cfg[:dst][:docker]}:localhost:2375 -L#{$cfg[:dst][:selenix]}:localhost:4444 -N #{ sshDstURI }")
  $cfg[:log].info "  Перенаправления портов запущены."
  sleep 1
  redir_ssh_pids = [redir_src_all, redir_dst_all]

  system "ssh #{ sshDstURI } 'mkdir -p #{ $cfg[:dst][:basepath] }; sudo systemctl start selenix'"
  src_list = JSON.parse Net::HTTP.get(URI("http://localhost:#{$cfg[:src][:docker]}/containers/json")), symbolize_names: true

  # по сессиям-контейнерам
  idlist.each do |u|
    $cfg[:log].info "  session #{ u[:sessionId] }"
    userHome      = "#{ $cfg[:dst][:basepath] }/home_#{ u[:customerId] }"
    container     = src_list.find{|rec| u[:sessionId] == parse_session_id(rec) } || next
    browser, version = (container[:Image] =~ /^selenoid\/vnc_(\w+):([0-9\.]+)$/) && [$1, $2] || next
    browserInfo     = JSON.parse(
                        Net::HTTP.get(
                          URI("http://localhost:#{$cfg[:src][:selenix]}/wd/hub/session/#{ u[:sessionId] }")),
                        symbolize_names: true
                      )
    srcChromeFolder = browserInfo[:value][:chrome][:userDataDir]
    srcChromeBaseFolder = srcChromeFolder[/\/([a-z\._\-A-Z0-9]+)$/, 1]
    exec_in_container( sshSrcURI, u[:sessionId], "bash -c 'sync;sync'" )
    source_size = exec_in_container( sshSrcURI, u[:sessionId], "bash -c 'du -sh #{ srcChromeFolder }'")[/^\s*(\w+)/, 1]

    $cfg[:log].info "    #{ userHome }; #{ browser }:#{ version }; #{ srcChromeBaseFolder }: #{ source_size }"

    File.write "/tmp/copy_data.sh", <<~ECOPYF
      #/usr/bin/bash
      set -e
      ssh #{ sshDstURI } "mkdir -p '#{ userHome }/.config'"
      curl --connect-timeout #{ $cfg[:curl][:connect_tmout] } \\
          -m  #{ $cfg[:curl][:copy_tmout] } \\
          -s 'http://localhost:#{ $cfg[:src][:docker] }/containers/#{ u[:sessionId] }/archive?path=#{ srcChromeFolder }' | \\
        gzip -c| \\
        ssh #{ sshDstURI } "gzip -dc -|tar Cxf '#{ userHome }/.config' -"

      ssh #{ sshDstURI } " \
          cd '#{ userHome }/.config' && \
          rm -rf google-chrome && \
          mv '#{ srcChromeBaseFolder }' google-chrome
          rm -f google-chrome/SingletonLock google-chrome/SingletonCookie google-chrome/SingletonSocket
          "
    ECOPYF
    FileUtils.chmod 0700, "/tmp/copy_data.sh"
    $cfg[:log].info "    Запускаю копирование профиля. Лог в /tmp/copy_data.log"
    assert( system("/tmp/copy_data.sh >> /tmp/copy_data.log 2>&1"), "Ошибка выполнения копирования. см. /tmp/copy_data.{sh,log}" )
    FileUtils.rm "/tmp/copy_data.sh"
    $cfg[:log].info "    Копирование #{ srcChromeBaseFolder } завершено. Создаю контейнер."

    nc = create_req(
        URI("http://localhost:#{ $cfg[:dst][:selenix] }/wd/hub/session"),
        build_conf(userHome, browser, version).to_json,
        $cfg[:max_attempt])
    assert( nc, "Ошибка создания контейнера" )
    $cfg[:log].info "    Создан контейнер с сессией #{ nc[:sessionId] }"

    dstContainerInfo = get_container_info( nc[:sessionId], "localhost", $cfg[:dst][:docker] )
    vncDstPort       = dstContainerInfo[:NetworkSettings][:Ports][:"5900/tcp"].first[:HostPort].to_i
    webdriverDstPort = dstContainerInfo[:NetworkSettings][:Ports][:"4444/tcp"].first[:HostPort].to_i
    redir_ssh_pids << spawn("ssh -f -n -A -L#{ vncDstPort }:localhost:#{ vncDstPort } -L#{ webdriverDstPort }:localhost:#{ webdriverDstPort } -N #{ sshDstURI }")
    $cfg[:log].info "    Нажимаю [ВВОД]"
    vnc_exec( 'localhost', vncDstPort, 'selenoid' ){|vnc| vnc.key_press :return }
#    sleep 5
#    session_check = Net::HTTP.get_response(URI "http://localhost:#{ $cfg[:dst][:selenix] }/wd/hub/session/#{ nc[:sessionId] }/window/handles" )
#   if session_check.code.to_i > 299
#     $cfg[:log].error "Проверка показала, что не получилось. #{ session_check.code }. #{ session_check.body.inspect }. Фотаю экран."
#   else
#     $cfg[:log].info "Проверка показала, что всё хорошо. #{ session_check.body.inspect }. Фотаю экран."
#   end
#   screenshot('localhost', webdriverDstPort, nc[:sessionId], dstIP)
   puts "#{ u[:customerId] };#{ nc[:sessionId] };#{ ggr_hash(dstIP, nc[:sessionId]) }"

#    $cfg[:log].info "    Убиваю Хром."
#    vnc_exec( 'localhost', vncDstPort, 'selenoid' ){|vnc| vnc.key_down :left_control; vnc.key_press 'w'; vnc.key_up :left_control }
#    exec_in_container sshDstURI, dstContainerInfo[:Id], "bash -c 'pidwait #{ browser }'"
#    sleep 0.3
#    $cfg[:log].info "    Создаю новую сессию."
#    newDstSession = start_session( 'localhost', webdriverDstPort, build_conf(userHome, browser, version) )
#    post( URI("http://localhost:#{ $cfg[:dst][:docker] }/containers/#{ dstContainerInfo[:Id] }/rename?name=#{ newDstSession[:sessionId] }"),
#            { name: newDstSession[:sessionId] }.to_json,
#            { 'Content-Type' => 'application/x-www-form-urlencoded' } )
#    exec_in_container sshDstURI, dstContainerInfo[:Id], "bash -c 'pidwait #{ browser }'"
#    sleep 0.33
#    $cfg[:log].info "    Новая сессия #{ newDstSession[:sessionId] }"
#    screenshot('localhost', $cfg[:dst][:selenix], newDstSession[:sessionId], dstIP)
#    puts "#{ u[:customerId] };#{ newDstSession[:sessionId] };#{ ggr_hash(dstIP, newDstSession[:sessionId]) }"
  end ### по сессиям-контейнерам

  $cfg[:log].info <<~ELOG
  Список контейнеров на #{ dstIP }
   ---
   #{ `ssh #{ sshDstURI } "docker ps -a"`.chomp }
   ---
  ELOG
  $cfg[:log].info "Конец копирования хоста #{ src_ip } в #{ dstIP }."
  killall redir_ssh_pids + get_ssh_redirections()

end ### по хостам
