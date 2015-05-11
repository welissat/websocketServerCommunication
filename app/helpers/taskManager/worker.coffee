'use strict'

conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
{EventEmitter} = require 'events'
Uuid = require 'uuid-lib'

delay = (ms, func) -> setTimeout func, ms

class Worker
  constructor: () ->
    @statusList = {
      ready: 'ready'
      busy: 'busy'
    }

    @workerId = Uuid.create()
    @workerEmitter = new EventEmitter()
    @status = @statusList.ready

  on: (emitName, fn) ->
    @workerEmitter.on emitName, fn

  once: (emitName, fn) ->
    @workerEmitter.once emitName, fn

  getWorkerId: () ->
    return @workerId

  startNewTask: (task, cb) ->
    if not @isReady()
      error = new Error("Cant start task. Worker #{@getWorkerId()} is not ready.")
      cb err
      return

    if task.getStatus() isnt 'locked'
      errLine = "worker #{@getWorkerId()} cant start task #{task.getTaskId()} because task not locked"
      Log.warn errLine
      error = new Error(errLine)
      cb error
      return

    @status = 'busy'
    task.setStatus('busy') #тут может быть сгенерирована ошибка, если статус не удалось поставить

    delay 1000, () =>
      task.setStatus 'completed'

      log.info "worker complete task #{task.getPayload()}"
      @status = @statusList.ready
      @workerEmitter.emit @status
      @workerEmitter.emit 'task.completed', null, task

      cb null

  isReady: () ->
    if @status is @statusList.ready
      return true
    else
      return false

module.exports = Worker