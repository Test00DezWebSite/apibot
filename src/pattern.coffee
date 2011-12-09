###
This is a Pattern. It's really just a regex on steroids.
###
class Pattern
  constructor: (regex, @callback) ->
    re = regex.toString().split('/')
    re.shift()
    modifiers = re.pop()
    
    pattern = re.join('/')
    
    @regex = new RegExp "(?:#{pattern})", modifiers
    return @
    
  responds_to: (message) ->
    @_matches(message)?
  
  _matches: (message) ->
    message.match(@regex)
  
  response: (message, user, callback) ->
    data = { user:user, matchdata:@_matches(message) }
    @callback data, (response) =>
      callback(response)

module.exports = Pattern
