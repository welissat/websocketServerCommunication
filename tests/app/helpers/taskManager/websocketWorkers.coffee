'use strict'
_ = require 'underscore'

Task = req('app/helpers/taskManager/task.coffee')

Worker = req('app/helpers/taskManager/websocketWorker.coffee')
WebsocketWorkers = req('app/helpers/taskManager/websocketWorkers.coffee')
WebSocketServer = req 'app/helpers/webSocket.coffee'
webSocketClient = require 'nodejs-websocket'
Uuid = require 'uuid-lib'

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


faker = require 'faker'

global.Log = req 'app/helpers/logger.coffee'

expect = require('chai').expect

describe 'new workers', () ->
  it 'should be init', (done) ->
    workers = new WebsocketWorkers()

    expect(workers).to.be.an.instanceof(WebsocketWorkers)
    done()

describe 'workers', () ->
  it 'should be save new workers', (done) ->
    workers = new WebsocketWorkers()
    maxWorkers = 3
    workersIdList = []

    checkAddedWorker = {}
    checkAddedWorker.checkedWorkers = []
    checkAddedWorker.check = (worker) ->
      workers.getWorkerById worker.getWorkerId(), (err, workerByWorkers) ->
        expect(err).to.be.equal(null)
        expect(workerByWorkers.getWorkerId()).to.be.equal(worker.getWorkerId())
        checkAddedWorker.checkedWorkers.push (workerByWorkers.getWorkerId()).toString()
        checkAddedWorker.checkedWorkers = _.uniq(checkAddedWorker.checkedWorkers)
        if checkAddedWorker.checkedWorkers.length >= maxWorkers
          done()


    webSocketServer.on 'client.connected', (err, wsClient) ->
      worker = new Worker(wsClient)
      workersIdList.push worker.getWorkerId()
      workers.addWorker worker, (err) ->
        expect(err).to.be.eql(null)
        workers.addWorker worker, (err) ->
          expect(err).not.to.be.eql(null)
          checkAddedWorker.check worker

    for i in [1..maxWorkers]
      workerId = Uuid.create().toString()
      do (workerId) ->
        clientPath = "ws://127.0.0.1:8090/id/#{workerId}"
        webSocketClient.connect clientPath, () ->




#console.log workersIdList
