# Examples

a place to experiment and learn

## Installation

Create a .env file in the root of the project.  (Note the .gitignore file keeping .env files out of source control)

### Streaming Server Example
Add this line to your .env file:
```
TIME_ON_THE_ROAD_VARIANCE=10
```
#### Usage
Open a console and navigate to the root of the project.  Type:
```
thin start -R StreamingServerConfig.ru -p 3000
```
(Ctrl+C followed by Y to interrupt the server)

Open up the WebSocketsClient.html to test

### WebSockets chat example using redis

Credit: [https://gist.github.com/ahaedike/a7f35c0bb9cc40fdc48e](https://gist.github.com/ahaedike/a7f35c0bb9cc40fdc48e)

Start up Redis I am using redis-server.exe on Windows.  To set up download redis-2.4.6-setup-32-bit.exe from [https://github.com/rgl/redis/downloads](https://github.com/rgl/redis/downloads)

```
ruby redis_pubsub_demo.rb
```

Open up RedisPubsubChatClient.html in multiple browser tabs or windows to see it in action

### Millsey_cycle_spambot

Credit: [http://stackoverflow.com/questions/7772057/read-file-in-eventmachine-asynchronous](http://stackoverflow.com/questions/7772057/read-file-in-eventmachine-asynchronous)

An [Event Machine](https://github.com/eventmachine/eventmachine) driven web sockets client that reads the GPS positions from a CSV file and sends them up to our cloud chat example where subscribes can see them as they came in (by default this is sped up by a factor of ten).  The client also subscribes to the updates so you'll see them come back as well as go up.

Event Machine uses the [Reactor Pattern](https://en.wikipedia.org/wiki/Reactor_pattern).  You'll probably get confused if you don't do at least some reading up on this pattern and the implications of blocking.  To illustrate the point study the 

```
EM.add_timer(time_to_wait/SPEED_UP_FACTOR) do
  ...
end    
```

block and consider the implication of replacing the delay with

```
sleep(time_to_wait/SPEED_UP_FACTOR) 
```

In itself this example is not particularly exciting.  In the next example we'll replace the web chat client with a map dynamically updating with the position.

One point to note in the dataset is that there are some relatively long delays in logging a GPS position.  We'll need to investigate these in the Android app to see what caused these.

Note that this example uses Pravigo::Duration which is based on ActiveSupport::Duration and will do some of the heavy lifting around durations in future examples and apps.

You can amend the following self-explanatory environment variables to run locally:

```
CYCLIST_HANDLE=Millsey
SPEED_UP_FACTOR=10
WEBSOCKETS_SERVER_ADDRESS=wss://pravigo-chat.herokuapp.com/
FILENAME=2015Jul12.csv
```

To run:

```
ruby millsey_cycle_spambot.rb
```


## Contributing

Whoever tries this first please add the gem install notes to this README and delete this line. Cheers

Otherwise standard procedure:

1. Fork it ( http://github.com/pravigo/examples/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
