var fs = require('fs');

module.exports = function(app, express, callback){
  loadEnvironments(app, express, function() {
    if(callback) callback();
  });
};

function loadEnvironments(app, express, callback) {
  var path = __dirname + '/environments';
  var files = fs.readdir(path, function(error, files) {
    if(error) throw error;
    
    loadEnvironment(app, express, files, 0, function() {
      if(callback) callback();
    });
  });
}

function loadEnvironment(app, express, files, index, callback) {
  var fileName = __dirname + '/environments/' + files[index];
  
  require(fileName)(app, express, function() {
    if(index === files.length-1 && callback) callback();
    else loadEnvironment(app, express, files, index+1, callback);
  }); 
}