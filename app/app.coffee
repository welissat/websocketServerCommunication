'use strict'

path = require 'path'
global.req = (name) ->
  require path.join(__dirname.replace('app', ''), name)

express = require 'express'
helmet = require 'helmet'

conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger'

app = express()
app.use(helmet)

port = conf.get('app:port');
app.listen port, (err) ->
  if err?
    log.error "cant listen #{port}"
  else
    log.info "app listening #{port}"

