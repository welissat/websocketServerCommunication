'use strict'
_ = require 'underscore'


faker = require 'faker'
Task = req('app/helpers/taskManager/task.coffee')
Tasks = req('app/helpers/taskManager/tasks.coffee')

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
    for i in [1..100]
      routine = faker.name.findName()
      task = new Task(routine)
      tasks.addNewTask task

    expect(tasks.taskList.length).to.be.equal(100)
    done()

  it 'should be get new task', (done) ->
    tasks = new Tasks()
    taskUUIDList = []
    for i in [1..100]
      routine = faker.name.findName()
      task = new Task(routine)
      taskUUIDList.push task.getTaskId().value
      tasks.addNewTask task

    tasks.getNewTask (err, task) ->
      expect(err).to.be.null
      expect(task.getTaskId().value).to.be.equal(taskUUIDList[0])
      expect(task.getStatus()).to.be.eql('locked')
      done()

  it 'should be moved completed task to completed queue', (done) ->
    tasks = new Tasks()
    taskUUIDList = []
    maxTasks = 10
    for i in [1..maxTasks]
      routine = faker.name.findName()
      task = new Task(routine)
      taskUUIDList.push task.getTaskId().value
      tasks.addNewTask task

    taskUUIDListShift = 0
    checkNext = () ->
      tasks.getNewTask (err, task) ->
        if not task?
          done()
        else
          expect(err).to.be.null
          expect(task.getTaskId().value).to.be.equal(taskUUIDList[taskUUIDListShift])
          expect(task.getStatus()).to.be.eql('locked')
          task.once 'completed', () ->
            setImmediate () ->
              taskUUIDListShift++
              checkNext()

          task.setStatus "completed"

    checkNext()
