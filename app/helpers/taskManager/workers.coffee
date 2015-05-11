'use strict'

_ = require 'underscore'
conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'

class Workers
  constructor: () ->
    @workers = []

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

  getWorkerById: (workerId, cb) ->
    for worker in @workers
      if worker.getWorkerId() is workerId
        cb null, worker
        return

    cb null

  safeInit: (cb) ->
    setImmidiate () ->
      cb null



module.exports = Workers