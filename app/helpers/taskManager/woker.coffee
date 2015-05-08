'use strict'

conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
{EventEmitter} = require 'events'

delay = (ms, func) -> setTimeout func, ms

class Worker
  constructor: (workerId) ->
    @statusList = {
      ready: 'ready'
      busy: 'busy'
    }

    @workerId = workerId
    @workerEmitter = new EventEmitter()
    @status = @statusList.ready

  on: (emitName, fn) ->
    @workerEmitter.on emitName, fm

  getWorkerId: () ->
    return @workerId

  startNewTask: (task, cb) ->
    if not @isReady()
      error = new Error("Cant start task. Worker #{@getWorkerId()} is not ready.")
      cb err
      return

    @status = 'busy'
    delay 10000, () =>
      log.info "worker complete task #{task}"
      @status = @statusList.ready
      @workerEmitter.emit @status
      cb null

  isReady: () ->
    if @status is statusCodes.ready
      return true
    else
      return false
