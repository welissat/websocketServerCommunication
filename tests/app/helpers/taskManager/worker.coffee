'use strict'
_ = require 'underscore'

Task = req('app/helpers/taskManager/task.coffee')
#TaskManager = req('app/helpers/taskManager/taskManager.coffee')
Worker = req('app/helpers/taskManager/worker.coffee')

global.Log = req 'app/helpers/logger.coffee'

expect = require('chai').expect

describe 'new worker', () ->
  it 'should be init', (done) ->
    worker = new Worker()

    expect(worker).to.be.an.instanceof(Worker)
    done()
