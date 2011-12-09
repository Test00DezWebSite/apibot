###
Abstract class for any interpreter
###
class Interpreter
  interpret: (message, user, callback) ->
    throw new Error 'Override this method!'

module.exports = Interpreter