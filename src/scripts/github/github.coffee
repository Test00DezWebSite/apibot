###
Github Interpreter

Interfaces with github's API
###
Interpreter = require "#{__dirname}/../../interpreter"
Pattern = require "#{__dirname}/../../pattern"
Https = require 'https'
Qs = require 'querystring'
Fs = require 'fs'
Url = require 'url'

# Load configuration
CONFIG = JSON.parse(Fs.readFileSync(__dirname + '/config.json', 'utf8'))

class Github extends Interpreter
  ###
  Register with Robot
  ###
  constructor: (@robot) ->
    @robot.register ['github', 'git', 'gist', 'commit', 'tag', 'comment', 'event', 'label', 'milestone', 'organization', 'org', 'member', 'team', 'pull request', 'repo', 'repository', 'collaborator', 'fork', 'key', 'watching', 'hook', 'user', 'email', 'follower'], @
  
  ###
  Given a message, strip out some junk and determine who to delegate to.
  ###
  interpret: (message, user, callback) ->
    message = message.replace /(\'s)/ig, ''
    message = message.replace /\b(what|how|who|when|where|will|please|are|can|you|show|see|get|fetch|from|at|in|of|github|git|i|me|my|on|for|how|many|does|have|the|an|a)\b/ig, ''
    message = message.replace /[?!,]/ig, ''
    message = message.replace /\s+/g, ' '
    message = message.replace /^\s+|\s+$/g, ''
    
    ###
    This is extreme meta-programming.
    
    for each class in Gitub:
      for each function in that class:
        add as an interpreter
    ###
    unless @interpreters
      @interpreters = []
      for klass of Github
        unless klass == '__super__'
          for phunction of eval("Github.#{klass}")
            @interpreters.push eval("Github.#{klass}.#{phunction}")
    
    ###
    Start interpreting from the beginning
    ###
    @_interpret 0, message, user, (response) ->
      callback(response)
                
  _interpret: (index, message, user, callback) ->
    if index == @interpreters.length
      return callback(null)
    
    interpreter = @interpreters[index]
    interpreter message, user, (pattern) =>
      if pattern.responds_to message
        pattern.response message, user, (response) ->
          return callback(response)
      else
        @_interpret(index+1, message, user, callback)
  
  ###
  Authenticate users via oauth. This method redirects users to the
  github oauth page. They are then redirected to a different URL,
  which makes a post request to acquire an access token. Then they
  are sent back here...
  ###
  @oauth: (code, user, callback) -> 
    @result = []

    url = Url.parse(CONFIG.accessTokenUrl)

    options = {
      hostname: url.hostname,
      path: url.path,
      method: 'POST'
    }
    
    request = Https.request options, (response) =>
      response.on 'data', (data) =>
        @result.push data
        
      response.on 'end', () =>
        result = Qs.parse @result.join('')
        if result.error
          callback result.error, null
        callback null, result.access_token
        
    
    request.on 'error', (error) ->
      console.log error
    
    request.write Qs.stringify(code:code, client_id:CONFIG[process.env.NODE_ENV || 'development']['clientId'], client_secret:CONFIG[process.env.NODE_ENV || 'development']['clientSecret'])
    request.end()
  
  class @Auth
    ###
    Authenticate the current user
    ###
    @auth: (message, user, callback) ->
      pattern = new Pattern /auth(enticate)?( me)?/i, (data, callback) ->
        response = []
        response.push 'We are authenticating you'
        response.push "<script>window.location.href = '#{CONFIG.authorizeUrl}?client_id=#{CONFIG[process.env.NODE_ENV || 'development'].clientId}'</script>"
        callback(response.join(''))
      callback(pattern)
      
  class @User
    ###
    Show the given user
    show me sethvargo's account
    ###
    @show: (message, user, callback) ->
      pattern = new Pattern /^(profile|account|info(rmation)?) ([A-Za-z0-9]+)$|^([A-Za-z0-9]+) (profile|account|info(rmation)?)$/i, (data, callback) ->
        username = data.matchdata[3] || data.matchdata[4]
        new Request { path:"/users/#{username}", user:user, view:'users/show' }, (response) ->
          callback(response)
      callback(pattern)

    ###
    Show the repos for the given username
    show me sethvargo's repos
    ###
    @repos: (message, user, callback) ->
      pattern = new Pattern /^(repos(itories)?) ([A-Za-z0-9]+)$|^([A-Za-z0-9]+) (repos(itories)?)$/i, (data, callback) ->
        username = data.matchdata[3] || data.matchdata[4]
        new Request { path:"/users/#{username}/repos", user:user, view:'repos/index' }, (response) ->
          callback(response)
      callback(pattern)

    ###
    Show the repos for the current user
    show me my repos
    ###
    @myRepos: (message, user, callback) ->
      pattern = new Pattern /^repos(itories)?$/i, (data, callback) ->
        new Request { path:"/user/repos", user:user, view:'repos/index' }, (response) ->
          callback(response)
      callback(pattern)

    ###
    Get a list of all orgs for a user
    show me sethvargo's orgs
    ###
    @orgs: (message, user, callback) ->
      pattern = new Pattern /^(org(s|anizations)) ([A-Za-z0-9]+)$|^([A-Za-z0-9]+) (org(s|anizations))$/i, (data, callback) ->
        username = data.matchdata[3] || data.matchdata[4]
        new Request { path:"/users/#{username}/orgs", user:user, view:'orgs/index' }, (response) ->
          callback(response)
      callback(pattern)

    ###
    Show the orgs of the current user
    show me my orgs
    ###
    @myOrgs: (message, user, callback) ->
      pattern = new Pattern /^org(s|anizations)$/i, (data, callback) ->
        new Request { path:"/user/orgs", user:user, view:'orgs/index' }, (response) ->
          callback(response)
      callback(pattern)
      
    ###
    Get a list of gists for the given user
    show me sethvargo's gists
    ###
    @gists: (message, user, callback) ->
      pattern = new Pattern /^gists? ([A-Za-z0-9]+)$|^([A-Za-z0-9]+) gists?$/i, (data, callback) ->
        username = data.matchdata[1] || data.matchdata[2]
        new Request { path:"/users/#{username}/gists", user:user, view:'gists/index' }, (response) ->
          callback(response)
      callback(pattern)
      
    ###
    Show the gists of the current user
    show me my gists
    ###
    @myGists: (message, user, callback) ->
      pattern = new Pattern /^gists?$/i, (data, callback) ->
        username = data.matchdata[3]
        new Request { path:"/gists", user:user, view:'gists/index' }, (response) ->
          callback(response)
      callback(pattern)

    ###
    Show the current user's starred gists
    show my starred gists
    ###
    @myStarredGists: (message, user, callback) ->
      pattern = new Pattern /^starred$/i, (data, callback) ->
        new Request { path:"/gists/starred", user:user, view:'gists/index' }, (response) ->
          callback(response)
      callback(pattern)

    ###
    Show the followers for the given user
    show me sethvargo's followers
    ###
    @followers: (message, user, callback) ->
      pattern = new Pattern /^followers? ([A-Za-z0-9]+)$|^([A-Za-z0-9]+) followers?$/i, (data, callback) ->
        username = data.matchdata[1] || data.matchdata[2]
        new Request { path:"/users/#{username}/followers", user:user, view:'users/index' }, (response) ->
          callback(response)
      callback(pattern)
  
    ###
    Show the followers for the current user
    show me sethvargo's followers
    ###
    @myFollowers: (message, user, callback) ->
      pattern = new Pattern /^followers$/i, (data, callback) ->
        new Request { path:"/user/followers", user:user, view:'users/index' }, (response) ->
          callback(response)
      callback(pattern)  
  
    ###
    Show the followings for the given user
    show me who sethvargo's following
    ###
    @followings: (message, user, callback) ->
      pattern = new Pattern /^followings? ([A-Za-z0-9]+)$|^([A-Za-z0-9]+) followings?$/i, (data, callback) ->
        username = data.matchdata[1] || data.matchdata[2]
        new Request { path:"/users/#{username}/following", user:user, view:'users/index' }, (response) ->
          callback(response)
      callback(pattern)
      
    ###
    Show the followings for the current user
    show me who sethvargo's following
    ###
    @myFollowings: (message, user, callback) ->
      pattern = new Pattern /^followings$/i, (data, callback) ->
        new Request { path:"/user/following", user:user, view:'users/index' }, (response) ->
          callback(response)
      callback(pattern)
  
  class @Gist
    ###
    Show the gist with the given :id
    show me gist #12345
    ###
    @show: (message, user, callback) ->
      pattern = new Pattern /^gist #?\s+?([0-9]+)$/i, (data, callback) ->
        id = data.matchdata[1]
        new Request { path:"/gists/#{id}", user:user, view:'gists/show' }, (response) ->
          callback(response)
      callback(pattern)   
  
  class @Org
    ###
    Get a single organization
    show me organization plaidlock
    ###
    @show: (message, user, callback) ->
      pattern = new Pattern /^org(anization)? ([A-Za-z0-9]+)$|^([A-Za-z0-9]+) org(anization)?$/i, (data, callback) ->
        organization = data.matchdata[2] || data.matchdata[3]
        new Request { path:"/orgs/#{organization}", user:user, view:'orgs/show' }, (response) ->
          callback(response)
      callback(pattern)    

    ###
    Show the repos for the given organization
    show me organization plaidlock's repos
    ###
    @repos: (message, user, callback) ->
      pattern = new Pattern /^org(anization)? ([A-Za-z0-9]+) repos(itories)?$|^repos(itories)? org(anization)? ([A-Za-z0-9]+)$/i, (data, callback) ->
        organization = data.matchdata[2] || data.matchdata[6]
        new Request { path:"/orgs/#{organization}/repos", user:user, view:'repos/index' }, (response) ->
          callback(response)
      callback(pattern)
      
    ###
    List all members of an organization
    show me plaidlock's members
    ###
    @members: (message, user, callback) ->
      pattern = new Pattern /^org(anization)? ([A-Za-z0-9]+) members(hips)?$|^members(hips)? org(anization)? ([A-Za-z0-9]+)$/i, (data, callback) ->
        organization = data.matchdata[2] || data.matchdata[6]
        new Request { path:"/orgs/#{organization}/members", user:user, view:'users/index' }, (response) ->
          callback(response)
      callback(pattern)

###
Request object. This is mostly just to avoid redundant code.
The Request object is just a glorified Https server.
###
class Request
  Jade = require 'jade'
  BASE_URL = 'api.github.com'

  constructor: (@options, @callback) ->
    @result = []
    @requestUrl = {
      hostname: BASE_URL,
      port: 443,
      path: options.path || '/',
      method: options.method || 'GET'
    }

    @options.user.findProviderByName 'github', (provider) =>
      if provider
        @requestUrl.path = @requestUrl.path + "?access_token=#{provider.token}"

      request = Https.request @requestUrl, (response) =>
        response.on 'data', (data) =>
          @result.push data

        response.on 'end', () =>          
          json = JSON.parse(@result.join(''))

          ###
          grab the statusCode and throw an error unless its a 200 OK
          ###
          statusCode = parseInt response.statusCode
          
          ###
          Render Jade (or error.jade) with the response in the locals hash
          ###
          Jade.renderFile @viewName(if statusCode/100 in [2,3] then @options.view else 'error'), { locals: {response:json} }, (error, html) =>
            if error
              throw error
            @callback(html)

      request.end()

      request.on 'error', (error) ->
        callback "Error in github: #{error}"

  ###
  Helper function to return the full path of the jade views
  ###
  viewName: (view) ->
    __dirname + '/views/' + view + '.jade'

module.exports = (robot) ->
  new Github(robot)

module.exports.getAccessToken = Github.oauth