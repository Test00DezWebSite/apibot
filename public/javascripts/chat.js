(function() {

  /*
  Chat
  This is an actual Chat "room". It is primarily responsible for
  accepting, creating, and formatting messages to and from the
  server.
  */

  var Chat;

  Chat = (function() {

    /*
      Creates a new Chat object with the given jQuery selectors by default
    */

    function Chat(chatArea, chatBox) {
      if (chatArea == null) chatArea = '#chat-area .content';
      if (chatBox == null) chatBox = '#chat-box';
      this.$chatArea = $(chatArea);
      this.$chatBox = $(chatBox);
      this.messageAnchor = 0;
      this.addListeners();
    }

    /*
      Adds two listeners:
      
        1. socket listener (socket.io) for messages coming from the server
        2. key listener for when the user presses the 'enter' key
    */

    Chat.prototype.addListeners = function() {
      var socket;
      var _this = this;
      socket = io.connect();
      socket.on('server-message', function(data) {
        return _this.removeSpinner(function() {
          _this.user = data.user;
          return _this.appendMessage(_this.chatMessage(data.sender, data.response), function() {});
        });
      });
      return this.$chatBox.keydown(function(e) {
        var data;
        if (e.keyCode === 13) {
          data = _this.$chatBox.val().replace(/^\s+|\s+$/g, '');
          _this.$chatBox.val('');
          _this.appendMessage(_this.chatMessage(_this.user, data), function() {
            return _this.addSpinner(function() {
              return socket.emit('client-message', {
                message: data
              });
            });
          });
          return false;
        }
      });
    };

    /*
      Simple wrapper function for appending a message and adjusting the
      scroll position.
    */

    Chat.prototype.appendMessage = function($message, callback) {
      var _this = this;
      this.$chatArea.append($message);
      prettyPrint();
      return $message.fadeIn('fast', function() {
        return _this.$chatArea.animate({
          scrollTop: _this.$chatArea.scrollTop() + $("\#message-" + _this.messageAnchor).offset().top - 50
        }, 'fast', function() {
          if (callback) return callback();
        });
      });
    };

    /*
      This jQuery code builds an actual chat object. Most of the styling is
      handled by the CSS classes.
    */

    Chat.prototype.chatMessage = function(user, message) {
      var $avatar, $clear, $content, $left, $messageWrapper, $right, $username;
      $messageWrapper = $('<div />');
      $messageWrapper.attr('id', "message-" + (++this.messageAnchor));
      $messageWrapper.addClass('message-wrapper');
      $left = $('<div />');
      $left.addClass('left');
      $avatar = $('<div />');
      $avatar.addClass('message-avatar');
      $avatar.css({
        'background': 'url(' + user.avatar + ')',
        'height': 48,
        'width': 48
      });
      $left.append($avatar);
      $right = $('<div />');
      $right.addClass('right');
      $username = $('<div />');
      $username.addClass('message-username');
      $username.html(user.username);
      $content = $('<div />');
      $content.addClass('message-message');
      $content.html(message);
      $right.append($username);
      $right.append($content);
      $clear = $('<div />');
      $clear.addClass('clear');
      $messageWrapper.append($left);
      $messageWrapper.append($right);
      $messageWrapper.append($clear);
      return $messageWrapper;
    };

    Chat.prototype.addSpinner = function(callback) {
      var $spinner;
      var _this = this;
      $spinner = $('<div />');
      $spinner.addClass('spinner');
      $spinner.appendTo(this.$chatArea);
      return $spinner.fadeIn('fast', function() {
        return _this.$chatArea.animate({
          scrollTop: _this.$chatArea.scrollTop() + $("\#message-" + _this.messageAnchor).offset().top
        }, 'slow', function() {
          return callback();
        });
      });
    };

    Chat.prototype.removeSpinner = function(callback) {
      var $spinner;
      var _this = this;
      $spinner = $('.spinner');
      if ($spinner.length) {
        return $spinner.fadeOut('fast', function() {
          $spinner.remove();
          return callback();
        });
      } else {
        return callback();
      }
    };

    return Chat;

  })();

  window.Chat = Chat;

}).call(this);
