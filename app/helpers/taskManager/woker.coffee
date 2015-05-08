'use strict'

conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
{EventEmitter} = require 'events'

delay = (ms, func) -> setTimeout func, ms

class Worker extends EventEmitter
  constructor: (workerId) ->
    @workerId = workerId
    #@workerEmitter = new EventEmitter()
    @status = 'ready'
  getWorkerId: () ->
    return @workerId

  startNewTask: (task, cb) ->
    @status = 'busy'
    delay 10000, () ->
      log.info "worker complete task #{task}"
      @status = 'ready'
      cb null
