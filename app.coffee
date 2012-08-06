#
# BanaJs
# author : dreampuf(soddyque@gmail.com)
#

express = require('express')
app = module.exports = express.createServer()
coffeekup = require 'coffeekup'
coffeekup.tags = coffeekup.tags.concat ["feed", "subtitle", "id", "updated", "author", "name", "rights"]
MemcachedStore = require('connect-memcached')(express)

config = require './config'
admin_route = require('./route/admin_route')
blog_route = require('./route/blog_route')

# Configuration
app.configure ()->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'coffee'
  app.set 'prodir', __dirname
  app.register('.coffee', coffeekup.adapters.express)
  #app.use express.compiler src: __dirname + '/public', enable: ['coffeescript']
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.methodOverride()
  #app.use app.router
  app.use express.static(__dirname + '/public')

  #app.use express.session
  #  key: "banajs"
  #  secret: "banajs"

  app.use (req, res, next)->
    res.local "config", config
    next()

app.configure 'development', ()->
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })
  #Session store put into third service for continue develop
  app.use express.session
    secret: "banajs"
    store: new MemcachedStore()

app.configure 'production', ()->
  #app.use(express.errorHandler())
  app.use express.session
    key: "banajs"
    secret: "banajs"

# Routes
admin_route(app)
blog_route(app)

app.listen 8081
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
