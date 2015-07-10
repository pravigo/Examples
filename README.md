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

## Contributing

Whoever tries this first please add the gem install notes to this README and delete this line. Cheers

Otherwise standard procedure:

1. Fork it ( http://github.com/pravigo/examples/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
