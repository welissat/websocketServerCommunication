'use strict'

nconf = require('nconf')
yaml = require('js-yaml')

module.exports = nconf.argv().env().file(
  file: 'config/config.yml'
  format:
    parse: yaml.safeLoad
    stringify: yaml.safeDump)
