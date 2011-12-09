var express = require('express');
var app = module.exports = express.createServer();

// Configuration
require(__dirname + '/config/application')(app, express, function() {
  
  // Routes
  var routes = require(__dirname + '/config/routes')(app);

  // Models
  require(app.settings.models)(app, function() {
    // Robot
    var Robot = require(app.settings.lib + '/robot');
    var robot = new Robot(app);

    // Socket IO
    var io = require(app.settings.root + '/config/socket.io')(app, express, robot);

    // Start the server
    app.listen(process.env.PORT || 3000, function() {
      console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
    });
  });
});