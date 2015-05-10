'use strict'

_ = require 'underscore'
conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'


class Tasks
  constructor: () ->
    @taskList = []
    @completedTask = []
  readyNewTask: () ->
    currentTask = _.first(@taskList)
    taskStatus = currentTask.getStatus()
    if taskStatus is 'ready'
      return true
    else
      return false

  getNewTask: (cb) ->
    currentTask = _.first(@taskList)
    currentTask.setStatus "locked" #задача занята, но ещё не отправлена воркеру
    cb null, currentTask


  addNewTask: (task, cb) ->
    @taskList.push task
    cb null

    task.once 'completed', () ->
      moveTaskToCompletedQueue(task)

  safeInit: (cb) ->
    for task in @taskList
      if task is "locked"
        log.warn "task #{task.getId()} was freezing. Unlocking"
        task.setStatus 'ready'
    cb null


module.exports = Tasks