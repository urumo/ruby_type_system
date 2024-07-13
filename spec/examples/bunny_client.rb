require 'bunny'
require 'json'

class BunnyClient < Bunny::Consumer
  ##
  # Router::Connection, String|Array, Router::Action, params: Hash == секция роутов,
  # если есть tmout: для ожидания сообщения -- значит работает один раз и выходит.
  # def initialize( mqconn, listen_key, action, params: {}, tmout: nil, queuename: nil )
  def initialize( cfg, worker )
    @cfg       = cfg
    @action    = worker
    @status    = :idle
    @cancelled = false
    @conn = @channel = @queue = @exchange = nil
    at_exit{ self.close }
    super( channel, queue, "#{ Cfg.app.id }.#{ @worker.class.to_s }", false, false )
    if cfg.routing_key.nil?    #  только подключиться к кролику
      exchange
    else                    # поднять клиента и слушать ключ
      # channel, queue, consumer_tag = channel.generate_consumer_tag, no_ack = false, exclusive = false, arguments = {}
      on_delivery do |a, b, c|
        @status = :job
        @worker.arbeiten!( a, b.to_hash, c )
        @status = :idle
      end
      queue.subscribe_with self
      Log.info{"Подслушиваю ключ #{ lk } на обменнике #{ exn } в очереди #{ queue.name }."}
      queue.bind( @exchange, routing_key: lk )
    end
    Thread.current.name = @action.class.to_s
    Log.debug{ self.inspect }
  end

  def connection
    if ! @conn || @conn.closed?
      Log.info{"#{ self.class.name } подключение #{ self.inspect }."}
      @conn = Bunny.new @cfg.conn.merge( logger: MQLog )
      @conn.start
    end
    @conn
    rescue Bunny::ChannelAlreadyClosed => e
      Log.warn{ "#{ self.class.to_s } переподключение #{ short_log }." }
      @conn = nil
      sleep( Cfg.app.tmout.mq_connection_retry || 0.5 )
      retry
  end

  def channel( reset: false )
    if ! @channel || @channel.closed?
      @channel = connection.create_channel
    end
    @channel
  end

  def queue
    if @queue.nil? || cancelled?
      @queue = channel.queue( @cfg.queue, cfg.rmq.defaults.queue )
    end
    @queue
    rescue Bunny::ChannelAlreadyClosed, Bunny::NotFound => e
      Log.warn{"Channel or queue is closed."}
      @channel = @exchange = nil
      sleep( Cfg.app.tmout.mq_connection_retry || 0.5 )
      retry
    rescue Bunny::PreconditionFailed => e
      Log.fatal { e.inspect }
      exit 2
  end

  def exchange
    @exchange = channel.exchange( @cfg.exchange, cfg.rmq.defaults.exchange )
    rescue Bunny::ChannelAlreadyClosed => e
      Log.warn{"Exchange #{ xname } is closed."}
      @channel = @exchange = nil
      sleep( Cfg.app.tmout.mq_connection_retry || 0.5 )
      retry
    rescue Bunny::PreconditionFailed => e
      Log.fatal { e.inspect }
      exit 1
  end

  def vhost; channel.connection.vhost; end
  def cancelled?; @cancelled; end
  def idle?; @status == :idle; end

  def handle_cancellation(_)
    Log.warn{ "Выключается #{ self.inspect }"}
    @cancelled = true
  end

  def close; self.cancel rescue nil; end


  def run!
  end

  # послать zak:json по указанному адресу
  def say( rkey, zak )
    exchange.publish( zak.to_json, { routing_key: rkey } )
  end

  def inspect
    out = "Потреблятель AMQP: #{ @action.nil? ? 'nil' : @action.name } conn:#{ @mqconn.inspect }, q:#{ @queue.name }-> x:#{ @route_params[:exchange] }"
    out += ", одноразовый (#{ @tmout }сек.) " if @tmout.present?
    out
  end
end
