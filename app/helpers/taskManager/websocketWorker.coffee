'use strict'

conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
Worker = req 'app/helpers/taskManager/worker'
{EventEmitter} = require 'events'

class WebsocketWorker extends Worker
  constructor: (websocketConnection) ->
    @websocketConnection = websocketConnection

    super()
    @setupListeners()

  setupListeners: () ->
    _this = @
    @websocketConnection.on 'text', (rawQuery) ->
      try
        query = JSON.parse(rawQuery)
        #console.log query
        if query.opCode?
          if query.opCode is 'set.status'
            _this.workerEmitter.emit 'set.status', null, query.payload
            return

          if query.opCode is 'set.task.status'
            _this.workerEmitter.emit 'set.task.status', null, query.payload
            return


      catch error
        console.log error
        Log.error error
        _this.workerEmitter.emit 'error', error

    @websocketConnection.on 'error', (err) =>
      @safeShutdown()


  safeShutdown: () ->
    @websocketConnection.close()
    @workerEmitter.emit 'safe.shutdown'
    @workerEmitter.removeAllListeners()
    @workerId = undefined;


  setWorkerId: () ->
    workerId = WebsocketWorker.getWorkerIdByPath @websocketConnection
    @workerId = workerId

  @getWorkerIdByPath : (websocketConnection) ->
    workerId = websocketConnection.path.split('/id/').join('')
    return workerId



  isReady: (cb) ->
    @sendCommandToWSClient 'get.status', {}, (err, status) ->
      if err?
        cb err
        return
      if status is 'ready'
        cb null, true
      else
        cb null, false

  workRootine: (task, cb) ->
    task.setStatus('busy')
    @sendCommandToWSClient 'send.work', task.getPayload(), (err) =>
      task.setStatus 'completed'

      log.info "task #{task.getTaskId()} was complete"
      @status = @statusList.ready
      @workerEmitter.emit @status
      @workerEmitter.emit 'task.completed', null, task
      cb err


  sendCommandToWSClient: (command, payload, cb) ->
    getStatusQuery = {opCode: command, payload: payload}
    getStatusQueryString = JSON.stringify(getStatusQuery)
    #console.log getStatusQueryString
    @once 'set.status', (err, status) ->
      cb err, status
    @once 'set.task.status', (err, status) ->
      #console.log "task done"
      cb err

    @websocketConnection.sendText getStatusQueryString, (err) ->
      #console.log err



module.exports = WebsocketWorker