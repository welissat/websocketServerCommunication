'use strict'
_ = require 'underscore'

Task = req('app/helpers/taskManager/task.coffee')

WebsocketWorker = req('app/helpers/taskManager/websocketWorker.coffee')
webSocketClient = require 'nodejs-websocket'
WebSocketServer = req 'app/helpers/webSocket.coffee'
faker = require 'faker'
Uuid = require 'uuid-lib'
delay = (ms, func) -> setTimeout func, ms

global.Log = req 'app/helpers/logger.coffee'

expect = require('chai').expect

webSocketServer = new WebSocketServer(8090)

wsClientEmulator = (wsclient) ->
  status = 'ready'
  wsclient.on 'text', (rawQuery) ->
    query = JSON.parse(rawQuery)
    if query.opCode is 'send.work'
      console.log "i get task", query.payload
      delay 100, () ->
        console.log "task completed", query.payload
        taskStatus = 'completed'
        answer = {opCode: 'set.task.status', payload: taskStatus}
        wsclient.sendText JSON.stringify(answer), () ->

    if query.opCode is 'get.status'
      answer = {opCode: 'set.status', payload: status}
      wsclient.sendText JSON.stringify(answer), () ->

describe 'new worker', () ->
  it 'should be init', (done) ->
    workerId = Uuid.create().toString()
    webSocketServer.once 'client.connected', (err, wsClient) ->
      #console.log "client connected", err, wsClient
      worker = new WebsocketWorker(wsClient)

      expect(worker).to.be.an.instanceof(WebsocketWorker)
      done()

    webSocketClient.connect "ws://127.0.0.1:8090/id/#{workerId}", () ->


  it 'should be ready', (done) ->
    workerId = Uuid.create().toString()
    webSocketServer.once 'client.connected', (err, wsClient) ->
      worker = new WebsocketWorker(wsClient)
      worker.isReady (err, isReady) ->
        expect(isReady).to.be.eql(true)
        done()
    webSocketClient.connect "ws://127.0.0.1:8090/id/#{workerId}", () ->
      wsClientEmulator @

describe 'worker', () ->
  it 'should not be complete a unlocked task', (done) ->
    workerId = Uuid.create().toString()
    webSocketServer.once 'client.connected', (err, wsClient) ->
      routine = faker.name.findName()
      task = new Task(routine)

      worker = new WebsocketWorker(wsClient)
      worker.once 'task.completed', () ->
        throw (new Error('unlocked task was completed'))
      worker.startNewTask task, (err) ->
        expect(err.message).include('because task not locked')
        done()
    webSocketClient.connect "ws://127.0.0.1:8090/id/#{workerId}", () ->
      wsClientEmulator @

  it 'should complete a locked task', (done) ->
    workerId = Uuid.create().toString()
    webSocketServer.once 'client.connected', (err, wsClient) ->

      completedGoal = (taskComplete, workerComplete) ->
        if taskComplete?
          completedGoal.taskComplete = true
        if workerComplete?
          completedGoal.workerComplete = true
        console.log "completedGoal", completedGoal.taskComplete, completedGoal.workerComplete
        if completedGoal.workerComplete and completedGoal.taskComplete
          done()

      routine = faker.name.findName()
      task = new Task(routine)
      task.setStatus 'locked'
      task.once 'completed', () ->
        completedGoal 'complete'

      worker = new WebsocketWorker(wsClient)
      worker.once 'task.completed', () ->
        completedGoal null, 'complete'
      worker.startNewTask task, (err) ->
        expect(err).to.be.eql(null)

    webSocketClient.connect "ws://127.0.0.1:8090/id/#{workerId}", () ->
      wsClientEmulator @
