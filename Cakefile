#Cakefile

{exec} = require "child_process"

REPORTER = "min"

task "test", "run tests", ->
  exec "mocha
    --compilers coffee:coffee-script/register
    --reporter #{REPORTER}
    --require coffee-script
    --require tests/test_helper.coffee
    --colors
    ./tests/app/helpers/
    ", (err, output) ->
      throw err if err
      console.log output