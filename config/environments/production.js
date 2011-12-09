module.exports = function(app, express, callback) {
  app.configure('production', function() {
    app.use(express.errorHandler());
  });
  
  if(callback) callback();
}