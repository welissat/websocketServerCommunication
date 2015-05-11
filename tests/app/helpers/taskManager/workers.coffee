'use strict'
_ = require 'underscore'

Task = req('app/helpers/taskManager/task.coffee')

Worker = req('app/helpers/taskManager/worker.coffee')
Workers = req('app/helpers/taskManager/workers.coffee')
faker = require 'faker'

global.Log = req 'app/helpers/logger.coffee'

expect = require('chai').expect

describe 'new workers', () ->
  it 'should be init', (done) ->
    workers = new Workers()

    expect(workers).to.be.an.instanceof(Workers)
    done()

describe 'workers', () ->
  it 'should be save new workers', (done) ->
    workers = new Workers()
    maxWorkers = 10
    workersIdList = []

    checkAddedWorker = {}
    checkAddedWorker.checkedWorkers = []
    checkAddedWorker.check = (worker) ->
      workers.getWorkerById worker.getWorkerId(), (err, workerByWorkers) ->
        expect(err).to.be.equal(null)
        expect(workerByWorkers.getWorkerId()).to.be.equal(worker.getWorkerId())
        checkAddedWorker.checkedWorkers.push (workerByWorkers.getWorkerId()).toString()
        checkAddedWorker.checkedWorkers = _.uniq(checkAddedWorker.checkedWorkers)
        if checkAddedWorker.checkedWorkers.length >= maxWorkers
          done()



    for i in [1..maxWorkers]
      worker = new Worker()
      do (worker) ->
        workersIdList.push worker.getWorkerId()
        workers.addWorker worker, (err) ->
          expect(err).to.be.eql(null)
          workers.addWorker worker, (err) ->
            expect(err).not.to.be.eql(null)
            checkAddedWorker.check worker


    #console.log workersIdList
