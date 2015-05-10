'use strict'

conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
{EventEmitter} = require 'events'

class Task
  constructor: (payload) ->
    @payload = payload

    @statusList = {
      ready: 'ready'
      locked: 'locked'
      completed: 'completed'
    }

    @status = @@statusList.ready
    @taskEmitter = new EventEmitter()

  on: (emitName, fn) ->
    @taskEmitter.on emitName, fn

  once: (emitName, fn) ->
    @taskEmitter.once emitName, fn

  setStatus: (status) ->
    if not @statusList[status]?
      errorLine ="unknown status #{status}"
      error = new Error(errorLine)
      Log.error error
      throw  error
      return

    @status = @statusList[status]
    if @status is @statusList.completed
      @taskEmitter.emit 'completed', null, @

  isReady: () ->
    if @status is @statusList.ready
      return true
    else
      return false

  getPayload: () ->
    return @payload


module.exports = Task
