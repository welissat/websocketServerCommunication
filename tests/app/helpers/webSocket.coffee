'use strict'
_ = require 'underscore'


faker = require 'faker'
conf = req 'app/helpers/config.coffee'
webSocketServer = req 'app/helpers/webSocket.coffee'
webSocketClient = require 'nodejs-websocket'

global.Log = req 'app/helpers/logger.coffee'

expect = require('chai').expect

describe 'websocket server', () ->
  it 'should be up', (done) ->
    webSocketClient.connect "ws://127.0.0.1:8090/id/123456", () ->
      @.on 'text', (rawQuery) ->
        try
          query = JSON.parse(rawQuery)
        catch e
          console.log e
          return

        #console.log query
        status = 'ready'
        if query.opCode?
          if query.opCode is 'get.status'
            answer = {status: "ready"}
            @sendText JSON.stringify(answer)
          if query.opCode is 'new.task'
            task = query.task
            answer = {status: "busy"}
            console.log "task"

    this.timeout 20000
