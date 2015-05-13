'use strict'
_ = require 'underscore'


faker = require 'faker'
conf = req 'app/helpers/config.coffee'
WebSocketServer = req 'app/helpers/webSocket.coffee'
webSocketClient = require 'nodejs-websocket'

global.Log = req 'app/helpers/logger.coffee'

expect = require('chai').expect

describe 'webSocketServer', () ->
  it 'should be startup', (done) ->
    webSocketServer = new WebSocketServer(8090)

    webSocketServer.once 'client.connected', (err, wsClient) ->
      expect(wsClient.readyState).to.be.equal(1)
      done()
    webSocketClient.connect "ws://127.0.0.1:8090", () ->
      #done()
