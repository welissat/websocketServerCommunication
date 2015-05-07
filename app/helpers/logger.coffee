'use strict'

winston = require 'winston'
changeCase = require 'change-case'

conf = req 'app/helpers/config.coffee'

fileLogFilename = "#{conf.get('logs:file:logsDir')}/#{changeCase.snake(conf.get('app:appName'))}.log"

fileLogSettings = {
  filename: fileLogFilename,
  maxsize: conf.get('logs:file:maxSize'),
  maxFiles: conf.get('logs:file:maxFiles'),
  handleExceptions: conf.get('logs:file:handleExceptions'),
  logstash: conf.get('logs:file:logstash'),
  timestamp: conf.get('logs:file:timestamp'),
  json: conf.get('logs:file:json'),
  prettyPrint: true,
  showLevel: conf.get('logs:file:showLevel')

}
console.log(fileLogSettings)
consoleLogSettings = {
  handleExceptions: conf.get('logs:console:handleExceptions'),
  timestamp: conf.get('logs:console:timestamp'),
  colorize: conf.get('logs:console:colorize'),
  prettyPrint: true,
  showLevel: conf.get('logs:console:showLevel')
}

logger = new (winston.Logger)(transports: [
  new (winston.transports.Console)(consoleLogSettings)
  new (winston.transports.File)(fileLogSettings)
])

module.exports = logger
