/*
  This magical index file loads all the models in it's directory
  and appends them to the models global settings object. It uses
  metaprogramming to make the application very extensible.
*/

var fs = require('fs');
var mongoose = require('mongoose');
var Schema = mongoose.Schema;

module.exports = function(app, callback) {
  app.set('models', {});
  
  mongoose.connect('mongodb://localhost/apibot');
  
  loadModels(app, function() {
    if(callback) callback();
  });
}

function loadModels(app, callback) {
  console.log('Loading models...');
  var path = __dirname;
  var files = fs.readdir(path, function(error, files) {
    if(error) throw error;
    
    loadModel(app, files, 0, function() {
      callback();
    });
  });
}

function loadModel(app, files, index, callback) {
  if(files[index] === 'index.js') return loadModel(app, files, index+1, callback);
  if(index === files.length) return callback();
    
  var fileName = __dirname + '/' + files[index];
  require(fileName)(app, mongoose, function() {
    var file = files[index].replace(/(\.js)/i, '');
    var file = file.charAt(0).toUpperCase() + file.slice(1); // capitalize
    console.log('  - '+file);
    loadModel(app, files, index+1, callback);
  }); 
}