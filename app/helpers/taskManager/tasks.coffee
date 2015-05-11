'use strict'

_ = require 'underscore'
conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
{EventEmitter} = require 'events'

class Tasks
  constructor: () ->
    @taskList = []
    @completedTasks = []
    @tasksEmitter = new EventEmitter()

  readyNewTask: () ->
    currentTask = _.first(@taskList)
    if not currentTask?
      @tasksEmitter.emit 'empty.tasklist'
      return false

    taskStatus = currentTask.getStatus()
    if taskStatus is 'ready'
      return true
    else
      return false

  on: (emitName, fn) ->
    @tasksEmitter.on emitName, fn

  once: (emitName, fn) ->
    @tasksEmitter.once emitName, fn

  getNewTask: (cb) ->
    currentTask = _.first(@taskList)
    if currentTask?
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

    task.once 'completed', () =>
      @moveTaskToCompletedQueue(task)

  moveTaskToCompletedQueue: (task) ->
    Log.info "moveTaskToCompletedQueue #{task.getTaskId().value}"
    saveToCompletedTaskIfNeed = (task) =>
      for completedTask in @completedTasks
        if task.getTaskId() is completedTask.getTaskId()
          Log.warn "task #{task.getTaskId().value} is exists in completedTask List"
          return

      @completedTasks.push task
      Log.info "task #{task.getTaskId().value} was added to completedTask List"
      return

    deleteFromTaskListIfNeed = (task) =>
      for index, waitingTask of @taskList
        if task.getTaskId() is waitingTask.getTaskId()
          @taskList[index] = null
          Log.info "task #{task.getTaskId().value} was deleted by taskList"

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
