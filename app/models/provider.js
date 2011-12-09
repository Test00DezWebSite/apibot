/*
  Provider

  An oauth provider table to store multiple authentications
 */
 
var crypto = require('crypto');

module.exports = function(app, mongoose, callback) {
  var Provider = new mongoose.Schema({
    name      : String,
    token     : { type:String, set:encrypt, get:decrypt }
  });
  
  var model = mongoose.model('Provider', Provider);
  if(!(model in app.settings.models))
    app.settings.models.Provider = model;

  if(callback) callback();
  return Provider;
  
  function encrypt(value) {
    value = value || '';
    var cipher = crypto.createCipher('aes-256-ecb', app.settings.encryptionKey);
    return cipher.update(value, 'utf8', 'hex') + cipher.final('hex');
  }

  function decrypt(value) {
    value = value || '';
    var decipher = crypto.createDecipher('aes-256-ecb', app.settings.encryptionKey);
    return decipher.update(value, 'hex', 'utf8') + decipher.final('utf8');
  }
}