'use strict'

conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
{EventEmitter} = require 'events'
Uuid = require 'uuid-lib'

class Task
  constructor: (payload) ->
    @payload = payload
    @uuid = Uuid.create()

    @statusList = {
      ready: 'ready'
      locked: 'locked'
      busy: 'busy'
      completed: 'completed'
    }

    @status = @statusList.ready
    @taskEmitter = new EventEmitter()

  on: (emitName, fn) ->
    @taskEmitter.on emitName, fn

  once: (emitName, fn) ->
    @taskEmitter.once emitName, fn

  getTaskId: () ->
    return @uuid

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

  getStatus: () ->
    return @status

  isReady: () ->
    if @status is @statusList.ready
      return true
    else
      return false

  isLocked: () ->
    if @status is @statusList.locked
      return true
    else
      return false

  setCompleted: (cb) ->
    @setStatus('completed')
    cb null


  getPayload: () ->
    return @payload


module.exports = Task
