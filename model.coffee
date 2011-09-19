# Model of BanaJs
# author: dreampuf(soddyque@gmail.com)

assert = require("assert")

sqlite3 = require("sqlite3").verbose()
helper = require("./helper")

drop_table = false
db = new sqlite3.Database "banajs.db", db_init
db_init = ()->
  tables =
    user: """
CREATE TABLE user (
  id INTEGER UNIQUE NOT NULL PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  nickname TEXT,
  last INTEGER,
  'create' INTEGER,
  readed TEXT
);""",
    content: """
CREATE TABLE content (
  path TEXT UNIQUE NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT,
  'create' INTEGER
);""",
    comment: """
CREATE TABLE comment (
  id INTEGER UNIQUE NOT NULL PRIMARY KEY AUTOINCREMENT,
  parent INTEGER,
  path TEXT NOT NULL,
  body TEXT,
  website TEXT,
  email TEXT,
  'create' INTEGER
);"""

  for key,sqlcreate of tables
    db.get "SELECT COUNT(*) as count FROM #{ key }", (err, ret)->
      if err
        db.exec sqlcreate


class ModelError extends Error
  constructor:(@message)->
    @name = "ModelError"
    @type = "ModelError"
    Error.call "ModelError"
    Error.captureStackTrace @, arguments.callee
    @

special_field = ["create"]
class BaseModel
  constructor:(@_name, model_info={})->
    #throw new ModelError("primary_key must in propertys") if model_info.primary_key == undefined
    model_info["primary_key"] = "id" if model_info.primary_key == undefined
    for k, v of model_info
      @[k] = v

  new:(p, cb)->
    keys = []
    vals = []

    for k, v of p
      #v = '"' + v + '"' if typeof v == "string"
      k = "'#{k}'" if k in special_field
      keys.push k
      vals.push v

    sql = "INSERT INTO #{@_name}(#{keys.join(",")})VALUES(#{("?" for i in vals).join(",")})"
    #console.log db.prepare sql
    #console.log vals
    db.run sql,vals, (err, ret)->
      if err
        if err.code == "SQLITE_CONSTRAINT"
          throw new ModelError "Table #{@_name} has a Constraint ModelError:\n #{vals}"
        else
          throw new ModelError err.message
      cb(ret)

  set:(p)->
    throw new ModelError("property MUST have '#{@primary_key}'") if p[@primary_key] == undefined
    
    id = p[@primary_key]
    delete p[@primary_key]
    keys = []
    vals = []

    for k, v of p
      #v = '"' + v + '"' if typeof v == "string"
      k = "'#{k}'" if k in special_field
      keys.push "#{k}=?"
      vals.push v

    sql = "UPDATE #{@_name} SET #{keys.join(",")} WHERE #{@primary_key}=#{id}"
    db.run sql,vals,(err, ret)->
      throw new ModelError(err.message) if err
  
  del:(id)->
    sql = "DELETE FROM #{@_name} WHERE #{@primary_key}=#{id}"
    db.exec sql, (err)->
      throw new ModelError(err.message) if err

  count:(cb)->
    args = arguments
    sql = "SELECT COUNT(*) as count FROM #{@_name}"
    if arguments.length >= 2
      sql += " WHERE #{args[0]}"
      cb = args[1]

    db.get sql, (err, row)->
      throw new ModelError(err.message) if err
      cb(row.count)

  get:(cb)->
    args = arguments
    sql = "SELECT * FROM #{@_name}"
    vals = []
    if arguments.length >= 2
      condition = ""
      for k, v of args[0]
        k = "'#{k}'" if k in special_field
        condition += if condition then " AND #{k}=?" else "#{k}=?"
        vals.push v

      sql += " WHERE #{condition}"
      cb = args[1]

    db.all sql, vals, (err, rows)->
      #console.log err if err
      throw new ModelError(err.message) if err
      cb(rows)

model = module.exports =
  User : new BaseModel("user",
    check: (email,pwd, cb)->
      @get
        email: email
        password: pwd
      , (rows)->
        cb rows
  )
  Content : new BaseModel("content", 
    primary_key : "path")
  Comment : new BaseModel "comment"

if require.main == module #Unit Test
  #drop_table = true
  #db_init()
  model.User.count (count)->
    emails = ("#{ helper.randstr 5 }@#{ helper.randstr 5}.#{helper.randstr 3}" for i in [0..5])
    email = emails[0]
    model.User.new
      email: email
      nickname: helper.randstr 5
      password: helper.sha1 ["123", "231", "312"][helper.rand 3]
      last: (new Date).getTime()
      create: (new Date).getTime()

    model.User.count (ncount)->
      assert.equal ncount, count + 1, "Why count now (#{ncount}) not equal before count (#{count})?"

      model.User.get (rows)->
        assert.ok rows.length > 0, "How could you return ZERO after data insert"
      
      model.User.get
        email:email
      , (rows)->
        assert.equal rows.length, 1

    #try
    #  model.User.get
    #    dd: "bb"
    #    qq: "cc"
    #  , (r)->
    #    console.log r
    #catch e
    #  console.log typeof e
    #  console.dir e
      
    
    #assert.throws ()->
    #  model.User.get
    #    dd:"bb"
    #  , (r)->
    #, ModelError

  #model.User.new
  #  email: "soddyque@gmail.com"
  #  nickname: "意义"
  #  password: helper.sha1 "123"
  #  last: (new Date).getTime()
  #  create: (new Date).getTime()
