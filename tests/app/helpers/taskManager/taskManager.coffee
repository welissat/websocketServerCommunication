'use strict'
_ = require 'underscore'

TaskManager = req('app/helpers/taskManager/taskManager.coffee')
Task = req('app/helpers/taskManager/task.coffee')
Tasks = req('app/helpers/taskManager/tasks.coffee')
Worker = req('app/helpers/taskManager/worker.coffee')

global.Log = req 'app/helpers/logger.coffee'
faker = require 'faker'

expect = require('chai').expect

describe 'new taskManager', () ->
  it 'should be exists', (done) ->
    taskManager = new TaskManager()

    expect(taskManager).to.be.an.instanceof(TaskManager)
    done()

describe 'taskManager', () ->
  it 'shoud be complete all tasks', (done) ->
    this.timeout(20000);
    maxTasks = 10
    tasks = new Tasks()
    worker = new Worker()
    for i in [1..maxTasks]
      routine = faker.name.findName()
      task = new Task(routine)
      #taskUUIDList.push task.getTaskId().value
      tasks.addNewTask task

    tasks.once 'empty.tasklist', () ->
      done()
    taskManager = new TaskManager(tasks, worker)
    taskManager.tasksLoop()
