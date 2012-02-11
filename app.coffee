#
# BanaJs
# author : dreampuf(soddyque@gmail.com)
#

express = require('express')
app = module.exports = express.createServer()
admin_route = require('./route/admin_route')
blog_route = require('./route/blog_route')

# Configuration
app.configure ()->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'coffee'
  app.set 'prodir', __dirname
  app.register('.coffee', require('coffeekup').adapters.express)
  #app.use express.compiler src: __dirname + '/public', enable: ['coffeescript']
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.methodOverride()
  #app.use app.router
  app.use express.static(__dirname + '/public')

  app.admin_path = '/admin'
  app.upfile_path = 'public/upfile'

app.configure 'development', ()->
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })
  #Session store put into third service for continue develop
  MemcacheStore = require "./connect-memcached"
  app.use express.session
    key: "banajs"
    secret: "banajs"
    store: new MemcacheStore({memcache_host: "127.0.0.1", memcache_port: 11211})

app.configure 'production', ()->
  app.use express.session
    key: "banajs"
    secret: "banajs"
  #app.use(express.errorHandler())

# Routes
admin_route(app)
blog_route(app)

app.listen 8081
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
