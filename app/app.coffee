'use strict'

path = require 'path'
global.req = (name) ->
  require path.join(__dirname.replace('app', ''), name)

express = require 'express'
helmet = require 'helmet'

conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
WebsocketWorkers = req 'app/helpers/taskManager/websocketWorkers.coffee'
WebSocketServer = req 'app/helpers/webSocket.coffee'

port = conf.get('app:port');

webSocketServer = new WebSocketServer(port)
websocketWorkers = new WebsocketWorkers(webSocketServer)
