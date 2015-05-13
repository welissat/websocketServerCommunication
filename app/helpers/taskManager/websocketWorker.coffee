'use strict'

conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'
Worker = req 'app/helpers/taskManager/worker'

class WebsocketWorker extends Worker
  constructor: (webSocketWorkerId, websocketConnection) ->
    @webSocketWorkerId = webSocketWorkerId
    @websocketConnection = websocketConnection
    super()
  setWorkerId: () ->
    console.log "set worker id", @webSocketWorkerId
    @workerId = @webSocketWorkerId



module.exports = WebsocketWorker