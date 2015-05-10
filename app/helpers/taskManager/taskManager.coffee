'use strict'

conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
{EventEmitter} = require 'events'

delay = (ms, func) -> setTimeout func, ms

class TaskManager
  constructor: (tasks, workers) ->
    @tasks = tasks
    @workers = workers

  tasksLoop: (worker) ->
    _this = @
    tasksLoopRoutine = () ->
      if not tasks.readyNewTask
        _this.tasks.on 'new_task', () ->
          tasksLoopRoutine()
      else
        _this.tasks.getNewTask (err, task) ->
          if err?
            delay (conf.get('taskManager:repeatDelay')), () ->
              tasksLoopRoutine()
          else
            workers.getWorkerById task.getWorkerId(), (err, worker) ->
              if err?
                delay (conf.get('taskManager:repeatDelay')), () ->
                  tasksLoopRoutine()
              else
                _this.taskLoop worker, task, () ->
                  tasksLoopRoutine()

    tasksLoopRoutine()

  taskLoop: (worker, task, cb) ->
    _this = @

    taskLoopRoutine = () ->
      if not task.isReady()
        task.once 'ready', () ->
          taskLoopRoutine()
      else
        _this.workerLoop worker, task, (err, completedTask) ->
          task.setCompleted (completedTask) ->
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
    workerLoopRoutine()

module.exports = TaskManager
