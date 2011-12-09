###
Chat
This is an actual Chat "room". It is primarily responsible for
accepting, creating, and formatting messages to and from the
server.
###
class Chat
  ###
  Creates a new Chat object with the given jQuery selectors by default
  ###
  constructor: (chatArea = '#chat-area .content', chatBox = '#chat-box') ->
    @$chatArea = $(chatArea)
    @$chatBox = $(chatBox)
  
    @messageAnchor = 0
  
    @addListeners()
  
  ###
  Adds two listeners:
  
    1. socket listener (socket.io) for messages coming from the server
    2. key listener for when the user presses the 'enter' key
  ###
  addListeners: () -> 
    socket = io.connect()
    socket.on 'server-message', (data) =>
      @removeSpinner =>
        @user = data.user
        @appendMessage @chatMessage(data.sender, data.response), =>
  
    @$chatBox.keydown (e) =>
      if e.keyCode == 13 # enter
        data = @$chatBox.val().replace /^\s+|\s+$/g, ''
        @$chatBox.val('')
    
        @appendMessage @chatMessage(@user, data), =>
          @addSpinner =>
            socket.emit('client-message', { message:data })
        false

  ###
  Simple wrapper function for appending a message and adjusting the
  scroll position.
  ###
  appendMessage: ($message, callback) ->
    @$chatArea.append($message)
    prettyPrint()
    $message.fadeIn 'fast', =>
      @$chatArea.animate {scrollTop: @$chatArea.scrollTop() + $("\#message-#{@messageAnchor}").offset().top - 50}, 'fast', ->
        callback() if callback

  ###
  This jQuery code builds an actual chat object. Most of the styling is
  handled by the CSS classes.
  ###
  chatMessage: (user, message) ->
    $messageWrapper = $('<div />')
    $messageWrapper.attr 'id', "message-#{++@messageAnchor}"
    $messageWrapper.addClass('message-wrapper')

    # left
    $left = $('<div />')
    $left.addClass('left')

    $avatar = $('<div />')
    $avatar.addClass('message-avatar')
    $avatar.css({'background':'url('+user.avatar+')', 'height':48, 'width':48})

    $left.append($avatar)

    # right
    $right = $('<div />')
    $right.addClass('right')

    $username = $('<div />')
    $username.addClass('message-username')
    $username.html(user.username)

    $content = $('<div />')
    $content.addClass('message-message')
    $content.html(message)

    $right.append($username)
    $right.append($content)

    # clear
    $clear = $('<div />')
    $clear.addClass('clear')

    # put it all together
    $messageWrapper.append($left)
    $messageWrapper.append($right)
    $messageWrapper.append($clear)

    $messageWrapper
    
  addSpinner: (callback) ->
    $spinner = $('<div />')
    $spinner.addClass 'spinner'
    $spinner.appendTo(@$chatArea)
    $spinner.fadeIn 'fast', =>
      @$chatArea.animate {scrollTop: @$chatArea.scrollTop() + $("\#message-#{@messageAnchor}").offset().top}, 'slow', ->
        callback()
        
  
  removeSpinner: (callback) ->
    $spinner = $('.spinner')
    if $spinner.length
      $spinner.fadeOut 'fast', =>
        $spinner.remove()
        callback()
    else
      callback()

window.Chat = Chat