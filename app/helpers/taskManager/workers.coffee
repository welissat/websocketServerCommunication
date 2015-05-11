'use strict'

_ = require 'underscore'
conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'

class Workers
  constructor: () ->
    @workers = []


module.exports = Tasks