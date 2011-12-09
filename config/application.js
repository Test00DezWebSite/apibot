var path = require('path');

module.exports = function(app, express, callback) {
  app.configure(function(){
    app.set('root', path.resolve(__dirname, '..'));
    app.set('views', app.settings.root + '/app/views');
    app.set('models', app.settings.root + '/app/models');
    app.set('lib', app.settings.root + '/lib');
    app.set('view engine', 'jade');
    app.set('encryptionKey', 'f349b56c5e27e131c5d324b7bf52dde7197fb56a880e6ba210ad61d37d6cfc367156f57004930c6669440e78c158f004114e36dad97bf6f0f87ab24b4ccfb2da');
    app.use(express.cookieParser());
    app.set('sessionStore', new express.session.MemoryStore());
    app.use(express.session({ key:'apibot', secret:'40e98f7ccbc27ca6e46c38602209efc5d9a372dc3dc2ca3b1ac9cc84dfa92ff1df9d686d218c6df69a3b81815afa52f9f85ce4d5e6e544eb3b26518a67db3908', store:app.settings.sessionStore }));
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(express.compiler({ src: app.settings.root + '/app/assets' , dest: app.settings.root + '/public', enable: ['less', 'coffeescript'] }));
    app.use(app.router);
    app.use(express.static(app.settings.root + '/public'));
  }); 
  
  app.dynamicHelpers({ 
    flash: function(request) { return request.flash(); },
    session: function(request, response) { return request.session }
  });
  
  console.log('Loaded configuration...');
  
  // grab the correct environment
  require(__dirname + '/environment')(app, express, function() {
    console.log('Loaded environments...');
    if(callback) callback();
  });
}