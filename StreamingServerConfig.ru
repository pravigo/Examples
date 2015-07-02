# -*- encoding: utf-8 -*-
# config.ru
require 'rack/stream'
require 'dotenv'
require "polyglot"
require "pp"
Dotenv.load(File.expand_path("../.env",  __FILE__))

Faye::WebSocket.load_adapter('thin')

class App
  include Rack::Stream::DSL
	
	
	stream do
	  after_open do
		
		EM.add_periodic_timer(30) {
          chunk "\n"
		  pp "keep alive"
	    }
		
		EM.add_periodic_timer(10) {
time_on_the_road = Random.rand(1..ENV['TIME_ON_THE_ROAD_VARIANCE'].to_i)
          chunk "Time on the road Mills to Wilkin #{time_on_the_road} seconds\n"
          pp "Time on the road Mills to Wilkin #{time_on_the_road} seconds\n"
    	}

	  end
	
  	  before_close do
  
	    chunk "END!\n"
	  end

  	  [200, {'Content-Type' => 'text/plain'}, []]
	end
		
		
	####

end


class TeamTrackFilter 
  include Rack::Stream::DSL
  
 
  def initialize(app)  
    @app = app  

  end  
  
  def call(env) 
    status, headers, response = @app.call(env)

    env['rack.stream'].instance_eval do
      before_chunk do |chunks|
          chunks.map { |chunk| 
            if chunk != "\n"
              "#{parser.parse(chunk).to_json}\n" rescue "#{chunk}\n"
            else
              "\n"
            end
      }
      end

    end
    [status, headers, response] 
  end
  
end  

app = Rack::Builder.app do
  use Rack::Stream
  use TeamTrackFilter
  run App.new
end

run app