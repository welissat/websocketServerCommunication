'use strict'

conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
{EventEmitter} = require 'events'

delay = (ms, func) -> setTimeout func, ms

class TaskManager
  constructor: (workerTasks, worker) ->
    @tasks = workerTasks
    @worker = worker

  safeInit: (cb) ->


  tasksLoop: () ->
    _this = @
    tasksLoopRoutine = () ->
      if not _this.tasks.readyNewTask()
        log.debug "ready new task"
        _this.tasks.once 'new.task', () ->
          tasksLoopRoutine()
      else
        log.info "trying get new task"
        _this.tasks.getNewTask (err, task) ->
          log.info "new task: #{task.getTaskId()}"
          if err?
            delay (conf.get('taskManager:repeatDelay')), () ->
              tasksLoopRoutine()
          else
            _this.taskLoop _this.worker, task, () ->
               setImmediate () ->
                 tasksLoopRoutine()

    tasksLoopRoutine()

  taskLoop: (worker, task, cb) ->
    _this = @

    taskLoopRoutine = () ->
      if not task.isLocked()
        log.debug "task is not locked"
        task.once 'ready', () ->
          taskLoopRoutine()
      else
        _this.workerLoop worker, task, (err, completedTask) ->
          task.setCompleted () ->
            cb null

    taskLoopRoutine()


  workerLoop: (worker, task, cb) ->
    _this = @
    workerLoopRoutine = () ->
      if not worker.isReady()
        worker.once 'ready', () ->
          workerLoopRoutine()

      else
        worker.startNewTask task, (err) ->
          if err?
            delay (conf.get('taskManager:repeatDelay')), () ->
              workerLoopRoutine()

    worker.once 'task.completed', (err, taskComleted) ->
      cb(err, taskComleted)
      return
    workerLoopRoutine()

module.exports = TaskManager
