'use strict'

conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
{EventEmitter} = require 'events'
ws = require 'nodejs-websocket'

class WebSocketServer
  constructor: (port) ->
    @websocketEventEmmiter = new EventEmitter()
    @port = port
    @startup()

  startup: () ->
    _this = @
    webSocketServer = ws.createServer (websocketConnection) ->
      _this.websocketEventEmmiter.emit 'client.connected', null, websocketConnection
    webSocketServer.listen @port

  getIdByWebsocketConnection: (websocketConnection) ->
    return websocketConnection.path

  on: (emitName, fn) ->
    @websocketEventEmmiter.on emitName, fn

  once: (emitName, fn) ->
    @websocketEventEmmiter.once emitName, fn

module.exports = WebSocketServer