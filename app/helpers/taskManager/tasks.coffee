'use strict'

_ = require 'underscore'
conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'


class Tasks
  constructor: () ->
    @taskList = []
    @completedTasks = []

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


  addNewTask: (task) ->
    taskId = task.getTaskId()
    if not taskId?
      errorLine = "cant add task without id"
      Log.error errorLine
      throw (new Error(errorLine))
      return

    @taskList.push task

    task.once 'completed', () ->
      moveTaskToCompletedQueue(task)
  moveTaskToCompletedQueue: (task) ->
    saveToCompletedTaskIfNeed = (task) ->
      for completedTask in @completedTasks
        if task.getTaskId() is completedTask.getTaskId()
          return
      @completedTasks.push task
      return

    deleteFromTaskListIfNeed = (task) ->
      for waitingTask in @taskList
        if task.getTaskId() is waitingTask.getTaskId
          waitingTask = null

      @taskList = _.compact(@taskList)
      return

    saveToCompletedTaskIfNeed task
    deleteFromTaskListIfNeed task
    return

  safeInit: (cb) ->
    for task in @taskList
      if task is "locked"
        log.warn "task #{task.getId()} was freezing. Unlocking"
        task.setStatus 'ready'
      if task is "completed"
        @moveTaskToCompletedQueue(task)

    cb null


module.exports = Tasks