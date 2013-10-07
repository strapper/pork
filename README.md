# pork

pork is an improved ```fork``` for node. Instead of keeping your event loop active until you call ```disconnect``` (and thus shutting down IPC), pork keeps your event loop active only when you have active listeners.

pork is useful when you want to run services in the background that shutdown when your code has finished running.

## Example

The following is an example of a program that porks a process, and sends and receives five pings/pongs. The process automatically exits after the fifth pong is received.

### main.coffee

    {pork} = require 'pork'
    server = pork "#{__dirname}/pong.js"

    pings = 0
    ping  = ->
      return if ++pings > 5
      setTimeout
        server.send 'ping'
        server.once 'message', (msg) ->
          console.log msg
          ping()
      , 1000

### pong.coffee

    require 'pork'

    process.on 'message', (msg) ->
      process.send 'pong'

## Limitations

pork currently uses stdin and stdout for IPC. In the future it will be changed to use an auxiliary handle like ```fork```.

## License

Copyright (c) 2013 Gerald Monaco. See the LICENSE.md file for license rights and
limitations (MIT).