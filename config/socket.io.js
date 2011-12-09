module.exports = function(app, express, robot) {
  var io = require('socket.io').listen(app);
  io.set('log level', 1);
  
  var cookieParser = express.cookieParser();

  /*
    This method intercepts the "handshake" and adds an authorization layer
  */
  io.set('authorization', function (data, callback) {
    if(!data.headers.cookie) return callback('No cookie transmitted!', false);

    // cookieParser sets data.cookies
    cookieParser(data, null, function() {
      data.sessionID = data.cookies['apibot'];
      
      var sessionStore = app.settings.sessionStore;
      sessionStore.get(data.sessionID, function(error, session) {
        if(error || !session) return callback('session terminated!');
        data.session = session;
        callback(null, true);
      });
    });
  });
  
  io.sockets.on('connection', function (socket) {
    var session = socket.handshake.session;
    var User = app.settings.models.User;
    
    User.findById(session.userId, function(error, user) {
      if(error) throw error;
      
      if(!user) return;
      
      var welcomeMessage = {
        sender:{
          username:robot.name,
          avatar:robot.avatar
        }, user:{
          username:user.name,
          avatar:user.avatar
        }, response:'Hey ' + user.name + '! Welcome to API Bot. Ask me questions and I\'ll try to answer them.'
      }
      socket.emit('server-message', welcomeMessage);
      
      socket.on('client-message', function(data) {
        robot.ask(data.message, user, function(response) {
          var sample = {
            sender:{
              username:robot.name,
              avatar:robot.avatar
            }, user:{
              username:user.name,
              avatar:user.avatar
            },
            response:response
          }
          socket.emit('server-message', sample);
        });
      });
    });
  });
  
  return io;
}