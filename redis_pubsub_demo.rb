# Start Redis on it's default port (or specify in your ENV)
# 
# Usage:
# ruby redis_pubsub_demo.rb
#

require 'rubygems'
require 'eventmachine'
require 'stringio'
require 'sinatra/base'
require 'em-websocket'
require 'yajl'


class EventedRedis < EM::Connection
  def self.connect
    host = (ENV['REDIS_HOST'] || 'localhost')
    port = (ENV['REDIS_PORT'] || 6379).to_i
    EM.connect host, port, self
  end

  def post_init
    @blocks = {}
  end
  
  def subscribe(*channels, &blk)
    channels.each { |c| @blocks[c.to_s] = blk }
    call_command('subscribe', *channels)
  end
  
  def publish(channel, msg)
    call_command('publish', channel, msg)
  end
  
  def unsubscribe
    call_command('unsubscribe')
  end
  
  def receive_data(data)
    buffer = StringIO.new(data)
    begin
      parts = read_response(buffer)
      if parts.is_a?(Array)
        ret = @blocks[parts[1]].call(parts)
        close_connection if ret === false
      end
    end while !buffer.eof?
  end
  
  private
  def read_response(buffer)
    type = buffer.read(1)
    case type
    when ':'
      buffer.gets.to_i
    when '*'
      size = buffer.gets.to_i
      parts = size.times.map { read_object(buffer) }
    else
      raise "unsupported response type"
    end
  end
  
  def read_object(data)
    type = data.read(1)
    case type
    when ':' # integer
      data.gets.to_i
    when '$'
      size = data.gets
      str = data.read(size.to_i)
      data.read(2) # crlf
      str
    else
      raise "read for object of type #{type} not implemented"
    end
  end
  
  # only support multi-bulk
  def call_command(*args)
    command = "*#{args.size}\r\n"
    args.each { |a|
      command << "$#{a.to_s.size}\r\n"
      command << a.to_s
      command << "\r\n"
    }
    send_data command
  end
end

class ChatController < EventMachine::WebSocket::Connection
  
  # Overrides
  def trigger_on_message(msg)
      received_data msg
  end
  
  def trigger_on_open
     create_redis
  end
  def trigger_on_close(event = {})
    handle_leave
    destroy_redis
  end
  # end Overrides
  
  def create_redis
    @pub = EventedRedis.connect
    @sub = EventedRedis.connect
  end
  
  def destroy_redis
    @pub.close_connection_after_writing
    @sub.close_connection_after_writing
  end
  
  def received_data(data)
    msg = parse_json(data)
    case msg[:action]
    when 'join'
      handle_join(msg)
    when 'message'
      handle_message(msg)
    else
      # skip
    end
  end
  
  def handle_join(msg)
    @user = msg[:user]
    subscribe
    publish :action => 'control', :user => @user, :message => 'joined the chat room'
  end
  
  def handle_leave
    publish :action => 'control', :user => @user, :message => 'left the chat room'
  end
  
  def handle_message(msg)
    publish msg.merge(:user => @user)
  end
  
  private
  def subscribe
    @sub.subscribe('chat') do |type,channel,message|
      debug [:redis_type, type]
      debug [:redis_channel, channel]
      debug [:redis_message, message]
      
      if type ==  "message"
        send message
      end
      
    end
  end
  
  def publish(message)
    @pub.publish('chat', encode_json(message))
  end
  
  def encode_json(obj)
    Yajl::Encoder.encode(obj)
  end
  
  def parse_json(str)
    Yajl::Parser.parse(str, :symbolize_keys => true)
  end
end

class StaticController < Sinatra::Base
  enable :inline_templates
  get('/') { erb :main }
end


# Let's go:  Fire up a webserver on port 3001 and a chat server on port 8082
EventMachine.run {
  EventMachine.start_server('0.0.0.0', 8082, ChatController, {:debug => true})
  Rack::Handler::Thin.run StaticController, :Port => 3001
}


