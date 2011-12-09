(function() {
  var init, showLoginBox;

  $(function() {
    init();
    return showLoginBox();
  });

  /*
  init
  - adds a listener for submitting the login form
  */

  init = function() {
    /*
      When submitting the login form, we post the serialized data
      back to the server. If the returned JSON indicates a successful
      login, we redirect the user to the chat room (the session has been
      established). Otherwise, we show them an error message and they can
      try again.
    */    return $('#login-form').submit(function() {
      var $form, $loginHelpText;
      $form = $(this);
      $loginHelpText = $('.login-help-text');
      $.post($form.attr('href'), $form.serialize(), function(data) {
        if (data.errors) {
          $loginHelpText.html(data.errors.join('<br />'));
          return $loginHelpText.addClass('error');
        } else if (data.user) {
          return window.location.replace(data.redirect);
        }
      });
      return false;
    });
  };

  /*
  This is mostly a UI hack. I wanted the login box to fade in for appeal,
  so I delay 0.25 seconds and then fade it in.
  */

  showLoginBox = function() {
    return setTimeout(function() {
      var $loginBox;
      $loginBox = $('#login-box');
      $loginBox.css({
        'top': $(window).height() / 2 - $loginBox.outerHeight() / 2
      });
      $loginBox.fadeIn('slow');
      return true;
    }, 250);
  };

}).call(this);
