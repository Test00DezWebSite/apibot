###
This is Robot. He's magical. This is the real guts of the application.
API Bot lives here, so does the NLP and application logic for parsing
incoming requests.
###
Fs          = require('fs')
Path        = require('path')
Natural     = require('natural')

class Robot
  ###
  Creates our robot
  ###
  constructor: (@app, @name = 'API Bot', @avatar = '/images/robot.jpg') ->
    @commands = []
    @interpreters = []
    @brain = new Natural.BayesClassifier()
    @loadPaths = []
    @failureMessages = [
      'Sorry, I don\'t understand \'#{message}\'. Could you rephrase?',
      '\'#{message}\' does not compute!'
    ]
    
    @load(__dirname + '/scripts')
    this
  
  name: ->
    @name
  
  avatar: ->
    @avatar
  
  ###
  Register an interpreter and it's keywords with Robot
  ###    
  register: (keywords, interpreter) ->
    index = @interpreters.length
    @brain.addDocument keywords, index
    @interpreters.push interpreter
    @brain.train()

  ###
  Ask Robot a question. He will use NLP to try and figure
  out what you want and pass off to the correct interpreter
  ###
  ask: (message, user, callback) ->
    classification = @brain.classify message
    return callback(@failureMessage(message)) unless classification
    return callback(@forceLogin()) unless user
    
    index = parseInt(classification)
    interpreter = @interpreters[index]
    interpreter.interpret message, user, (result) =>
      if result? then callback(result) else callback(@failureMessage(message))
  
  ###
  Helper method for failure messages
  ###
  failureMessage: (message) ->
    # return a random failure message
    rand = Math.floor Math.random()*@failureMessages.length
    failureMessage = @failureMessages[rand]
    return failureMessage.replace /#{message}/ig, message
  
  ###
  This is a handy little function that uses XSS to force a login if the
  socket is no longer valid.
  ###
  forceLogin: () ->
    '<script type="text/javascript">window.location.replace("\/");</script>'
  
  load: (path) ->
    Path.exists path, (exists) =>
      if exists
        @loadPaths.push(path)
        files = Fs.readdirSync(path)
        for f in files
          @loadFile path, f
  
  loadFile: (path, f) ->
    fullPath = Path.join(path, f)
    Fs.stat fullPath, (error, stats) =>
      if error
        throw error
        
      if stats.isDirectory()
        @load fullPath
      else if stats.isFile()
        ext = Path.extname f
        
        if ext == '.js'
          try
            require(fullPath)(@)
          catch e
            console.log "Error requiring #{fullPath}: #{e}"
  
module.exports = Robot