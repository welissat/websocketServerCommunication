'use strict'
_ = require 'underscore'


faker = require 'faker'
redis = require 'redis'
conf = req 'app/helpers/config.coffee'
Task = req('app/helpers/taskManager/task.coffee')
Tasks = req('app/helpers/taskManager/redisTasks.coffee')
redisServerHost = conf.get('redis:serverHost')
redisServerPort = conf.get('redis:serverPort')
global.Log = req 'app/helpers/logger.coffee'
Log.info "prepare for connection to redis://#{redisServerHost}:#{redisServerPort}"
redisClient = redis.createClient(redisServerPort, redisServerHost);
Uuid = require 'uuid-lib'


expect = require('chai').expect

describe 'new tasks', () ->
  it 'should be init', (done) ->
    tasks = new Tasks(redisClient)
    expect(tasks).to.be.an.instanceof(Tasks)
    done()

describe 'tasks list', () ->
  it 'should be support addNewTask', (done) ->
    clientId = Uuid.create()
    redisKey = "newtask.#{clientId}"
    tasks = new Tasks(redisClient, redisKey)

    for i in [1..100]
      routine = faker.name.findName()
      task = new Task(routine)
      tasks.addNewTask task

    #expect(tasks.taskList.length).to.be.equal(queueLength) DEPRECATED
    done()

  it 'should be get new task', (done) ->
    clientId = Uuid.create()
    redisKey = "newtask.#{clientId}"
    tasksOrig = []
    tasks = new Tasks(redisClient, redisKey)
    for i in [1..100]
      routine = faker.name.findName()
      task = new Task(routine)
      tasks.addNewTask task
      tasksOrig.push task
      #TODO - need async await

    tasks.getNewTask (err, task) ->
      expect(err).to.be.null
      expect(task.getPayload()).to.be.equal(_.last(tasksOrig).getPayload())
      done()

  it 'should be moved completed task to completed queue', (done) ->
    this.timeout(20000);
    clientId = Uuid.create()
    redisKey = "newtask.#{clientId}"
    tasksOrig = []
    tasks = new Tasks(redisClient, redisKey)
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
          expect(task.getStatus()).to.be.eql('locked')
          task.once 'completed', () ->
            setImmediate () ->
              taskUUIDListShift++
              checkNext()

          task.setStatus "completed"
    checkNext()

