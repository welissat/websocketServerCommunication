'use strict'

conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
{EventEmitter} = require 'events'

ws = require "nodejs-websocket"
webSocketServer = ws.createServer (websocketConnection) ->

  path = websocketConnection.path
  readyState = websocketConnection.readyState

  websocketConnection.on 'text', (rawQuery) ->
    try
      query = JSON.parse(rawQuery)
    catch e
      log.error e
      return
    #console.log query
    if query.status?
      status = query.status
      log.info "worker #{path} status: #{status}"


  getStatusQuery = {opCode: "get.status"}
  websocketConnection.sendText JSON.stringify(getStatusQuery)



webSocketServer.listen conf.get("app:websocketPort")
module.exports = webSocketServer