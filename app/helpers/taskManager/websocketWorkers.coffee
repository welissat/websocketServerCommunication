'use strict'

_ = require 'underscore'
conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
Workers = req 'app/helpers/taskManager/Workers'
WebsocketWorker = req 'app/helpers/taskManager/websocketWorker'
TaskManager = req 'app/helpers/taskManager/taskManager'
RedisTasks = req 'app/helpers/taskManager/redisTasks'
redisClient = req 'app/helpers/redis'

class WebsocketWorkers extends Workers

  constructor: (webSocketServer) ->
    @workers = []
    @webSocketServer = webSocketServer

    @workersEco = {}

  setup: () ->
    @webSocketServer.on 'client.connected', (err, websocketClient) =>
      @addWorker websocketClient, (err, worker) =>
        if not err?
          @initWorker worker

  addWorker: (websocketClient, cb) ->

    @getWorkerById WebsocketWorker.getWorkerIdByPath(websocketClient), (err, localWorker) =>
      if err?
        throw err
      else
        if localWorker?
          errorLine = "worker #{localWorker.getWorkerId()} allready added"
          log.warn errorLine
          error = new Error(errorLine)
          cb error
        else
          worker = new WebsocketWorker(websocketClient)

          cb null, worker

  initWorker: (worker) ->
    tasks = new RedisTasks(redisClient)
    taskManager = new TaskManager(tasks, worker)
    @workers.push worker
    @workersEco[worker.getWorkerId()] =
      worker: worker
      tasks: tasks
      taskManager: taskManager

    process.nextTick () ->
      taskManager.tasksLoop()



  addWorker: (worker, cb) ->
    @getWorkerById worker.getWorkerId(), (err, localWorker) =>
      if err?
        throw err
      else
        if localWorker?
          errorLine = "worker #{localWorker.getWorkerId()} allready added"
          log.warn errorLine
          error = new Error(errorLine)
          cb error
        else
          @workers.push worker
          cb null

  deleteWorker: (worker, cb) ->
    workerEco =  @workersEco[worker.getWorkerId()]
    if workerEco?
      worker.safeShutdown()
      tasks.safeShutdown()



module.exports = WebsocketWorkers