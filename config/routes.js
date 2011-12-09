module.exports = function(app) {
  
  /* root */
  app.get('/', function(request, response){
    response.render('index', { title: 'API Bot' });
  });
  
  /* login */
  app.post('/', function(request, response) {    
    var name = request.body.name;
    var password = request.body.password;
    
    if(name === '' && password === '') {
      if(request.xhr) {
        response.json({errors:['You must enter a username and password!']});
      } else {
        request.flash(errors, ['You must enter a username and password!'])
        response.render('index', { title: 'API Bot' });
      }
      
      return;
    }

    var User = app.settings.models.User;

    User.findOne({ 'name':name }, function(error, user) {
      if(error) throw error;
      
      if(user) {
        // user record exists
        if(user.password === password) {
          // if the passwords match, log them in
          request.session.userId = user._id;
          if(request.xhr) {
            response.json({user:true, redirect:'/room'});
          } else {
            response.redirect('/room');
          }
        } else {
          // password was wrong
          if(request.xhr) {
            response.json({errors:['That username is already taken!', 'The passwords did not match.']});
          } else {
            request.flash('error', 'That username is already taken!', 'The passwords did not match.')
            response.render('index', { title: 'API Bot' });
          }
        }
      } else {
        // no user, create an account
        var u = new User({ name:name, password:password, avatar:'/images/avatar.jpg' });
        u.save(function(error) {
          if(error) throw error;
          
          request.session.userId = u._id;
          if(request.xhr) {
            response.json({user:u, redirect:'/room'});
          } else {
            response.redirect('/room');
          }
        });
      }
    });
  });
  
  /* chat room */
  app.get('/room', requireLogin, function(request, response) {
    response.render('room', { title: 'Chat Room' });
  });
  
  function requireLogin(request, response, callback) {
    if(!request.session.userId) {
      request.flash('error', 'You must be logged in to do that!');
      return response.redirect('/');
    }
    callback();
  }
  
  /* github oauth */
  app.get('/oauth/github', requireLogin, function(request, response) {
    var User = app.settings.models.User;
    var code = request.query.code;
    var userId = request.session.userId;
    
    User.findById(userId, function(error, user) {
      if(error) throw error;
      request.flash('error', 'You must be logged in to do that!');
      if(!user) return response.redirect('/');
      
      require(app.settings.lib + '/scripts/github/github').getAccessToken(code, user, function(error, accessToken){
        if(error) {
          console.log(error);
          request.flash('error', 'There was a problem authenticating your github account, please try again.');
          return response.redirect('/');
        }
        
        user.findOrCreateProviderByName('github', function(provider) {
          if(provider) {
            provider.token = accessToken;
            user.save(function(error) {
              if(error) {
                console.log(error);
                request.flash('error', 'Oh snap. Something happened. We aren\'t sure what went wrong, but we\'re looking into it...');
                return response.redirect('/room');
              }
              
              request.flash('notice', 'You have been authenticated to github!');
              return response.redirect('/room');
            });
          } else {
            console.log('No provider');
            request.flash('error', 'Oh snap. Something happened. We aren\'t sure what went wrong, but we\'re looking into it...');
            return response.redirect('/room');
          }
        });
      });
    });
  });
  
}