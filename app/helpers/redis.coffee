'use strict'

redis = require 'redis'
conf = req 'app/helpers/config.coffee'
log = req 'app/helpers/logger'
#redis.createClient() = redis.createClient(6379, '127.0.0.1', {})

redisServerHost = conf.get('redis:serverHost')
redisServerPort = conf.get('redis:serverPort')
log.info "prepare for connection to redis://#{redisServerHost}:#{redisServerPort}"
redisClient = redis.createClient(redisServerPort, redisServerHost);
log.info "redis status: #{redisClient.connected}"

module.exports = redisClient