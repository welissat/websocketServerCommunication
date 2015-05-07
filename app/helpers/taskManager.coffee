conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger.coffee'

class WorkersPool
  constructor: () ->
    @workers = {}

    addWorker: (worker, cb) ->
      auth worker, (err) =>
        if err?
          cb err
        else
          workerId = worker.getId()
          @workers[workerId] = worker
          log.info "worker #{workerId} status: was added to workerPool"
        cb null

    auth: (worker, cb) ->
      workerId = worker.getId()
      if @workers[workerId]?
        error = new Error("worker #{workerId} exists")
        log.error error
        cb error
      else
        log.info "worker #{workerId} status: auth successful"
        cb null

    setAuth: (authFn, cb) ->
      @auth = authFn
      cb null

class Worker
  constructor: (workerId) ->
    @workerId = workerId
    @birthTime = new Date()
  getId: () ->
    return @workerId


class WorkersQueuePool
  constructor: () ->
    workersQueue = {}

class WorkerQueueHandler
  constructor()

class TaskManager
  constructor () ->
    @workers = {}
    @workersQueue = {}

  setNewClient (worker) ->

  setNewTaskQueueToClient(workerQueue) ->
