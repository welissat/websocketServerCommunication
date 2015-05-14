'use strict'

conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
{EventEmitter} = require 'events'
Uuid = require 'uuid-lib'
Tasks = req('app/helpers/taskManager/tasks.coffee')
Task = req('app/helpers/taskManager/task.coffee')

class RedisTasks extends  Tasks
  constructor: (redisClient, queueId, completedQueueId) ->
    @redisClient = redisClient
    @queueId = queueId
    @completedQueueId = "completed.#{queueId}"
    @status = "ready"
    super()

  readyNewTask: (cb) ->
    @redisClient.lrange @queueId, -1, 1, (err, payloads) ->
      if err?
        cb err
      else
        if payloads?
          if payloads.length > 0
            cb null, true
          else
            cb null, false
        else
          cb false

  getTaskId: () ->
    return @queueId

  addNewTask: (task, cb) ->
    #TODO need new task event(pub/sub)
    @redisClient.rpush @queueId, task.getPayload(), (err) =>
      if cb? then cb

  getNewTask: (cb) ->
    _this = @
    if @status isnt "ready"
      @once 'ready', () ->
        setImmediate () ->
          _this.getNewTask cb
    else
      @redisClient.lrange @queueId, -1, -1, (err, payloads) ->
        if not payloads?
          cb err, null
        else
          payload = payloads[0]
          if not payload?
            cb err
          else
            currentTask = new Task(payload)
            currentTask.setStatus "locked"
            currentTask.once 'completed', () ->
              _this.moveTaskToCompletedQueue(currentTask)

            _this.status = "locked"
            cb err, currentTask

  moveTaskToCompletedQueue: (task) ->
    @redisClient.multi()
    .rpush(@completedQueueId, task.getPayload())
    .lrem(@queueId, -1, task.getPayload())
    .exec (err, answers) =>
      @status = 'ready'
      @tasksEmitter.emit 'ready'


module.exports = RedisTasks