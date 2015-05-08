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
          @workers[worker.getId()] = worker
          log.info "worker #{worker.getId()} status: was added to workerPool"
        cb null

    auth: (worker, cb) ->
      if @workers[worker.getId()]?
        error = new Error("worker #{worker.getId()} exists")
        log.error error
        cb error
      else
        log.info "worker #{worker.getId()} status: auth successful"
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
  startNewTask: (task, cb) ->
    @taskManager.startNewTask task, (err) ->
      cb err
  setTaskManager: (taskManager) ->
    @taskManager = taskManager

class AbstractTaskManager
  constructor: () ->
  startNewTask: (task) ->
    throw "method AbstractTaskManager.startNewTask not implemented"

class WebSocketTaskManager extends  TaskManager
  constructor: (clientSocket) ->
    @super()
    @setClientAnswers();
    @clientSocket = clientSocket

  setClientAnswers: () ->
    @status = {
      'connected': 'connected'
      'disconnected': 'disconnected'
      'busy': 'busy'
      'ready': 'ready'
    }

  startNewTask: (task, cb) ->
    @getClientStatus (err, clientStatus) =>
      if err?
        cb err
      else
        if clientStatus is @status.ready
          @sendNewTaskToClient task, (err) ->
            cb err

    sendNewTaskToClient: (task, cb) ->
      @clientSocket.emit "start.new.task", task, (answer) =>
        if @getClientStatusByAnswer is @status.connected




class WorkersQueuePoolManager
  constructor: (worker) ->
    @worker = worker
    workersQueue = {}

  startNextTask: (task, cb) ->
    @worker.isReadyForNewTask (err, ready) =>
      if err?
        cb err
      else
        if ready is false
          log.info "worker #{@worker.getId()} status: not ready for new task"
          error = new Error("worker #{@worker.getId()} not ready for new task")
          cb err
        else
          @worker.startNewTask task, (err) =>
            cb err
