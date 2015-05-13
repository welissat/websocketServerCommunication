'use strict'
_ = require 'underscore'

Task = req('app/helpers/taskManager/task.coffee')

Worker = req('app/helpers/taskManager/worker.coffee')
faker = require 'faker'

global.Log = req 'app/helpers/logger.coffee'

expect = require('chai').expect

describe 'new worker', () ->
  it 'should be init', (done) ->
    worker = new Worker()

    expect(worker).to.be.an.instanceof(Worker)
    done()

  it 'should be ready', (done) ->
    worker = new Worker()
    worker.isReady (err, workerReady) ->
      expect(workerReady).to.be.eql(true)
      done()

describe 'worker', () ->
  it 'should not be complete a unlocked task', (done) ->
    routine = faker.name.findName()
    task = new Task(routine)

    worker = new Worker()
    worker.once 'task.completed', () ->
      throw (new Error('unlocked task was completed'))
    worker.startNewTask task, (err) ->
      #because task not locked
      expect(err.message).include('because task not locked')
      done()

  it 'should complete a locked task', (done) ->

    completedGoal = (taskComplete, workerComplete) ->
      if taskComplete?
        completedGoal.taskComplete = true
      if workerComplete?
        completedGoal.workerComplete = true
      #console.log completedGoal
      if completedGoal.workerComplete and completedGoal.taskComplete
        done()

    routine = faker.name.findName()
    task = new Task(routine)
    task.setStatus 'locked'
    task.once 'completed', () ->
      completedGoal 'complete'

    worker = new Worker()
    worker.once 'task.completed', () ->
      completedGoal null, 'complete'
    worker.startNewTask task, (err) ->
      expect(err).to.be.eql(null)
