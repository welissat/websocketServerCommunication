'use strict'
_ = require 'underscore'


faker = require 'faker'
Task = req('app/helpers/taskManager/task.coffee')
Tasks = req('app/helpers/taskManager/tasks.coffee')
TaskManager = req('app/helpers/taskManager/taskManager.coffee')
global.Log = req 'app/helpers/logger.coffee'

expect = require('chai').expect

describe 'new tasks', () ->
  it 'should be init', (done) ->
    tasks = new Tasks()
    expect(tasks).to.be.an.instanceof(Tasks)
    done()

describe 'tasks list', () ->
  it 'should be support addNewTask', (done) ->
    tasks = new Tasks()
    for i in [1..1000]
      routine = faker.name.findName()
      task = new Task(routine)
      tasks.addNewTask task

    expect(tasks.taskList.length).to.be.equal(1000)
    done()
