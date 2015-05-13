'use strict'

conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
{EventEmitter} = require 'events'
Uuid = require 'uuid-lib'
Tasks = req('app/helpers/taskManager/tasks.coffee')

class RedisTasks extends  Tasks

module.exports = RedisTasks