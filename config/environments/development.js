module.exports = function(app, express, callback) {
  app.configure('development', function() {
    app.use(express.errorHandler({
      dumpExceptions: true,
      showStack: true
    }));
    
    if(callback) callback();
  });
}