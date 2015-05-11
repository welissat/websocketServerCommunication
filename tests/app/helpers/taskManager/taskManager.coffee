'use strict'
_ = require 'underscore'

TaskManager = req('app/helpers/taskManager/taskManager.coffee')

describe 'taskManager', () ->
  it 'should be exists', (done) ->
    taskManager = new TaskManager()
    done()