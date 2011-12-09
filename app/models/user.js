/*
  User
  
  Simple user with embedded oauth providers
 */

module.exports = function(app, mongoose, callback) {
  var crypto = require('crypto');  
  var Provider = require('./provider')(app, mongoose);
  
  var User = new mongoose.Schema({
    name          : { type:String, trim:true, required:true, index:true, unique:true },
    password      : { type:String, trim:true, required:true, set:encrypt, get:decrypt },
    avatar        : { type:String, trim:true },
    created_at    : { type:Date, default:Date.now },
    providers     : [Provider],
    chat_log      : { type:String, default:null },
    last_login    : Date
  });
  
  User.methods.findProviderByName = function(name, callback) {
    for(var i = 0;i < this.providers.length; i++) {
      var provider = this.providers[i];
      
      if(provider.name === name) {
        return callback(provider);
      }
    }
    
    return callback(null);
  }
  
  User.methods.findOrCreateProviderByName = function(name, callback) {
    var _this = this;
    _this.findProviderByName(name, function(provider) {
      if(provider) return callback(provider);
      _this.providers.push({name:name});
      callback(_this.providers[_this.providers.length-1]);
    });
  }
  
  var model = mongoose.model('User', User);
  if(!(model in app.settings.models))
    app.settings.models.User = model;

  if(callback) callback();
  return User;
  
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
};