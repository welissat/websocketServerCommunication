'use strict'
_ = require 'underscore'

TaskManager = req('app/helpers/taskManager/taskManager.coffee')


workerMock = {}
taskMock = {}

tasksMock = {}
tasksMock.tasks = [taskMock]
tasksMock.readyNewTask = true
tasksMock.getNewTask = (cb) ->
  task = _.last(tasksMock.tasks)
  cb null, task

describe 'taskManager', () ->
  it 'should be exists', (done) ->
    taskManager = new TaskManager()
    done()