'use strict'

path = require 'path'
rewire = require 'rewire'

getPath = (name) ->
  return path.join(__dirname.replace('tests', ''), name)

global.req = (name) ->
  return require(getPath(name));

global.rewire = (name) ->
  return rewire(getPath(name))

