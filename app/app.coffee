'use strict'

path = require 'path'
global.req = (name) ->
  require path.join(__dirname.replace('app', ''), name)

express = require 'express'
helmet = require 'helmet'
conf = req 'app/helpers/config.coffee'

app = express()
app.use(helmet)

port = conf.get('app:port');
console.log 'port', port
app.listen(port)
