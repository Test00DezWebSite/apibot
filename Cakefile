Fs = require 'fs.extra'
Path = require 'path'
{exec} = require 'child_process'

task 'compile', 'Copies everything from src to lib and compiles all coffee files', ->
  exec "cp -r #{__dirname}/src/ #{__dirname}/lib/ && coffee -c #{__dirname}/lib/ && find #{__dirname}/lib/ -name '*.coffee' -exec rm {} \\;", (error, stdout, stderr) ->
    if error
      throw error
    console.log stdout + stderr