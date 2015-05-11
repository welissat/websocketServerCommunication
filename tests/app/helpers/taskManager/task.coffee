'use strict'
_ = require 'underscore'

Task = req('app/helpers/taskManager/task.coffee')
TaskManager = req('app/helpers/taskManager/taskManager.coffee')
global.Log = req 'app/helpers/logger.coffee'

expect = require('chai').expect

describe 'new task', () ->
  it 'should be init', (done) ->
    task = new Task("test task")
    expect(task).to.be.an.instanceof(Task)
    done()
  it 'should be ready', (done) ->
    task = new Task('test task')
    expect(task.isReady()).to.be.equal(true)
    done()

describe 'task', () ->
  it 'should be lockable', (done) ->
    task = new Task('test task')
    task.setStatus('locked')
    expect(task.isReady()).to.be.equal(false)
    expect(task.getStatus()).to.be.equal('locked')
    done()
  it 'should be get payload', (done) ->
    payload = "test task payload"
    task = new Task(payload)
    expect(task.getPayload()).to.be.equal(payload)
    done()

  it 'should be emit "complete" after task was complete', (done) ->
    payload = "task test emit"
    task = new Task(payload)
    task.setStatus('locked')
    task.once 'completed', () ->
      done()
    task.setStatus "completed"