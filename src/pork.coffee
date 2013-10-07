{spawn} = require 'child_process'
byline  = require 'byline'

extend = (object, properties) ->
  return object unless properties?
  for key, value of properties
    object[key] = value
  return object

initChannel = (proc, stdin, stdout) ->
  stdin = byline stdin
  stdin.on 'data', (msg) ->
    proc.emit 'message', JSON.parse msg

  proc.send = (msg) ->
    stdout.write "#{JSON.stringify msg}\n"

if process.env.NODE_STDIO_FORKED?
  initChannel process, process.stdin, process.stdout

pork = (modulePath) ->
  if arguments[1] instanceof Array
    args    = arguments[1]
    options = extend {}, arguments[2]
  else
    args = []
    options = extend {}, arguments[1]

  execArgv = options.execArgv ? process.execArgv
  args     = execArgv.concat [ modulePath ], args

  options.execPath ?= process.execPath
  options.detached ?= true
  options.env       = extend options.env ? process.env, { NODE_STDIO_FORKED: true }

  proc = spawn options.execPath, args, options
  stdio.unref() for stdio in proc.stdio
  proc.unref()

  initChannel proc, proc.stdout, proc.stdin

  proc.on 'newListener', (evnt) ->
    return unless evnt == 'message'
    proc.ref()

  proc.on 'removeListener', (evnt) ->
    return unless evnt == 'message'
    proc.unref()

module.exports = {
  pork
}