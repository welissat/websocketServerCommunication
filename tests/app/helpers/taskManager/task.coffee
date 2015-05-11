'use strict'
_ = require 'underscore'

Task = req('app/helpers/taskManager/task.coffee')
TaskManager = req('app/helpers/taskManager/taskManager.coffee')

expect = require('chai').expect

describe 'task', () ->
  it 'init', (done) ->
    task = new Task("test task")
    expect(task).to.be.an.instanceof(Task)
    done()
  it 'new task is ready', (done) ->
    task = new Task('test task')
    expect(task.isReady()).to.be.equal(true)
    done()
