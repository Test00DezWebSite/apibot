$ ->
  init();
  showLoginBox();

###
init
- adds a listener for submitting the login form
###
init = () ->
  ###
  When submitting the login form, we post the serialized data
  back to the server. If the returned JSON indicates a successful
  login, we redirect the user to the chat room (the session has been
  established). Otherwise, we show them an error message and they can
  try again.
  ###
  $('#login-form').submit ->
    $form = $(this);
    $loginHelpText = $('.login-help-text');

    $.post $form.attr('href'), $form.serialize(), (data)->
      if data.errors
        $loginHelpText.html(data.errors.join('<br />'));
        $loginHelpText.addClass('error');
      else if data.user
        window.location.replace(data.redirect);
        
    return false;

###
This is mostly a UI hack. I wanted the login box to fade in for appeal,
so I delay 0.25 seconds and then fade it in.
###
showLoginBox = () ->
  setTimeout ->
    $loginBox = $('#login-box');

    $loginBox.css({ 'top': $(window).height()/2 - $loginBox.outerHeight()/2 });
    $loginBox.fadeIn('slow');
    true;
  , 250