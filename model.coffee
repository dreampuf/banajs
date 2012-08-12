# Model of BanaJs
# author: dreampuf(soddyque@gmail.com)

assert = require("assert")

helper = require("./helper")
fs = require 'fs'
path = require 'path'

###### Model ############

env_home = "./db"
class Model
  hasPro = Object::hasOwnProperty
  constructor:(@db_name, methods)->
    @dbpath = "#{ env_home }/#{ @db_name }"
    if not path.existsSync @dbpath
      fs.writeFileSync @dbpath, JSON.stringify([])
    data = fs.readFileSync @dbpath
    @db = JSON.parse data

    for i, k of methods
      @[i] = k

  sync:(cb)->
    data = JSON.stringify @db
    if cb
      fs.writeFile @dbpath, data, (err)->
        throw err if err
        cb()
    else
      fs.writeFileSync @dbpath, data

  put:(obj, cb)->
    modifed = false
    if obj.id #modify
      for i, n in @db
        if i.id == obj.id
          @db[n] = obj
          modifed = true
          break
    
    if not modifed #new
      @db.push obj
    @sync cb

Content = new Model "Content", {
  # title
  # path
  # create
  # modify
  # content
  # content_html
  # content_outline
  # content_feed #runtime
  # author
  sort_by_create : (desc=false)->
    smap = [1, 0, -1]
    smap.reverse() if desc
    ds = (i for i in @db)
    ds.sort (a, b)->
      if a.create > b.create then smap[0] else if a.create == b.create then smap[1] else smap[2]
    ds
  get : (d)->
    if d.path
      (i for i in @db when i.path == d.path)[0]

  id : ()->
    max = 0
    for i in @db
      max = if max > i.id then max else i.id
    max + 1
}
User = new Model "User", {
  # email
  # nickname
  # password
  get : (d)->
    if d.email
      m = d.email
      (i for i in @db when i.email == m)[0]
    else
      m = d.id
      (i for i in @db when i.email == m)[0]
  check : (email, password)->
    (i for i in @db when i.email == email and i.password == password)[0]
}
Comment = new Model "Comment", {
  # id
  # content
  # email
  # url
  # checked
  id : ()->
    max = 0
    for i in @db
      max = if max > i.id then max else i.id
    max + 1
}

models = module.exports =
  Content : Content
  User : User
  Comment : Comment

if require.main == module
  do()-> #test Model
