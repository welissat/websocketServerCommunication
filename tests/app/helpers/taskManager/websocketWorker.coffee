'use strict'
_ = require 'underscore'

Task = req('app/helpers/taskManager/task.coffee')

WebsocketWorker = req('app/helpers/taskManager/websocketWorker.coffee')
webSocketClient = require 'nodejs-websocket'
webSocketServer = req 'app/helpers/webSocket.coffee'
faker = require 'faker'
Uuid = require 'uuid-lib'

global.Log = req 'app/helpers/logger.coffee'

expect = require('chai').expect

describe 'new worker', () ->
  it 'should be init', (done) ->
    workerId = Uuid.create().toString()
    webSocketClient.connect "ws://127.0.0.1:8090/id/#{workerId}", () ->
      worker = new WebsocketWorker(workerId, @)

      expect(worker).to.be.an.instanceof(WebsocketWorker)
      done()

  it 'should be ready', (done) ->
    worker = new WebsocketWorker()
    worker.isReady (err, isReady) ->
      expect(isReady).to.be.eql(true)
    done()

describe 'worker', () ->
  it 'should not be complete a unlocked task', (done) ->
    workerId = Uuid.create().toString()
    webSocketClient.connect "ws://127.0.0.1:8090/id/#{workerId}", () ->
      routine = faker.name.findName()
      task = new Task(routine)

      worker = new WebsocketWorker(workerId, @)
      worker.once 'task.completed', () ->
        throw (new Error('unlocked task was completed'))
      worker.startNewTask task, (err) ->
        expect(err.message).include('because task not locked')
        done()

  it 'should complete a locked task', (done) ->
    workerId = Uuid.create().toString()
    webSocketClient.connect "ws://127.0.0.1:8090/id/#{workerId}", () ->

      completedGoal = (taskComplete, workerComplete) ->
        if taskComplete?
          completedGoal.taskComplete = true
        if workerComplete?
          completedGoal.workerComplete = true
        #console.log completedGoal
        if completedGoal.workerComplete and completedGoal.taskComplete
          done()

      routine = faker.name.findName()
      task = new Task(routine)
      task.setStatus 'locked'
      task.once 'completed', () ->
        completedGoal 'complete'

      worker = new WebsocketWorker(workerId, @)
      worker.once 'task.completed', () ->
        completedGoal null, 'complete'
      worker.startNewTask task, (err) ->
        expect(err).to.be.eql(null)
