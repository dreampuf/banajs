# Model of BanaJs
# author: dreampuf(soddyque@gmail.com)

assert = require("assert")

helper = require("./helper")
fs = require 'fs'
path = require 'path'
Buffer = require('buffer').Buffer
bdb = require 'bdb'

###### Model ############

with_db_Sync = (func)->
  env_home = "./db"
  fs.mkdirSync env_home, 0750 if not path.existsSync(env_home)
  bdb_env = new bdb.DbEnv()
  stat = bdb_env.openSync home: env_home
  assert.equal 0, stat.code, stat.message
  bdb_db = new bdb.Db bdb_env
  stat = bdb_db.openSync env: bdb_env, file:"db"
  assert.equal 0, stat.code, stat.message
  
  func(bdb_db)

  #stat = bdb_db.closeSync()
  #assert.equal 0, stat.code, stat.message
  #stat = bdb_env.closeSync()
  #assert.equal 0, stat.code, stat.message
  
with_db = (func)->
  env_home = "./db"
  path.exists env_home, (exists)->
    if not exists
      fs.mkdirSync env_home, 0750
    bdb_env = new bdb.DbEnv()
    stat = bdb_env.openSync home: env_home
    assert.equal 0, stat.code, stat.message
    bdb_db = new bdb.Db bdb_env
    stat = bdb_db.openSync env: bdb_env, file:"db"
    assert.equal 0, stat.code, stat.message
    
    func bdb_db

    #stat = bdb_db.closeSync()
    #assert.equal 0, stat.code, stat.message
    #stat = bdb_env.closeSync()
    #assert.equal 0, stat.code, stat.message

class Model
  hasPro = Object::hasOwnProperty
  constructor:(@db_name, methods)->
    @db_name_bf = new Buffer "table:#{ @db_name }"
    env_home = "./db"
    fs.mkdirSync env_home, 0750 if not path.existsSync(env_home)
    bdb_env = new bdb.DbEnv()
    stat = bdb_env.openSync home: env_home
    assert.equal 0, stat.code, stat.message
    bdb_db = new bdb.Db bdb_env
    stat = bdb_db.openSync env: bdb_env, file:"db"
    assert.equal 0, stat.code, stat.message
    
    db = bdb_db.getSync key:@db_name_bf
    if db.code == 0
      @db = JSON.parse db.value.toString()
    else
      @db = []
    for i, k of methods
      @constructor::[i] = k

    #stat = bdb_db.closeSync()
    #assert.equal 0, stat.code, stat.message
    #stat = bdb_env.closeSync()
    #assert.equal 0, stat.code, stat.message

  sync:(cb)->
    datas = new Buffer JSON.stringify @db
    if cb
      with_db (bdb_db)=>
        bdb_db.put {key: @db_name_bf, val: datas}, (res)->
          cb res
    else
      with_db_Sync (bdb_db)=>
        bdb_db.putSync {key: @db_name_bf, val: datas}

  put:(obj, cb)->
    @db.push obj
    @sync cb

Content = new Model "Content", {
  # title
  # create
  # modify
  # body
  # author
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
