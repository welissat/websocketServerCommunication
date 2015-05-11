'use strict'
_ = require 'underscore'

Task = req('app/helpers/taskManager/task.coffee')
TaskManager = req('app/helpers/taskManager/taskManager.coffee')
global.Log = req 'app/helpers/logger.coffee'

expect = require('chai').expect
