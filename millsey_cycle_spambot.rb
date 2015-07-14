require 'csv'
require 'dotenv'
require 'pravigo/duration'
require 'faye/websocket'
require 'eventmachine'
require 'json'


Dotenv.load(File.expand_path("../.env",  __FILE__))

SPEED_UP_FACTOR = (ENV['SPEED_UP_FACTOR'].to_i || 10)
WEBSOCKETS_SERVER_ADDRESS = (ENV['WEBSOCKETS_SERVER_ADDRESS'] || 'wss://pravigo-chat.herokuapp.com/')
FILENAME = (ENV['FILENAME'] || "2015Jul12.csv")
CYCLIST_HANDLE = (ENV['CYCLIST_HANDLE'] || "Millsey")

EM.run {
  
  ws = Faye::WebSocket::Client.new(WEBSOCKETS_SERVER_ADDRESS)

  io = File.open(FILENAME)
  previous_line = nil
  time_to_wait = 5
  io.gets

  read_chunk = proc do
      puts "."
      if line = io.gets 

        if !previous_line.blank?
          current_time = Time.parse(CSV.parse(line)[0][0])
          previous_time = Time.parse(CSV.parse(previous_line)[0][0])
          time_to_wait = Duration.new(current_time-previous_time).to_i
          message = { handle: CYCLIST_HANDLE, text: "#{CSV.parse(line)}"}
          ws.send(message.to_json)
          EM.add_timer(time_to_wait/SPEED_UP_FACTOR) do
            puts "I waited #{time_to_wait} seconds"
            previous_line = line
            EM.next_tick(read_chunk)
          end    
        else
          previous_line = line
          EM.next_tick(read_chunk)
        end
      else
        ws.close
        #EM.stop
      end
    
    end
    
  
  ws.on :open do |event|
    p [:open]
    
    EM.next_tick(read_chunk)
  end

  ws.on :message do |event|
    p [:message, event.data]
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
    EM.stop
  end
  

}