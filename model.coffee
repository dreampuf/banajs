# Model of BanaJs
# author: dreampuf(soddyque@gmail.com)


sqlite3 = require("sqlite3").verbose()
drop_table = false
db = new sqlite3.Database "banajs.db", ()->
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

special_field = ["create"]
class BaseModel
  constructor:(@_name, model_info={})->
    #throw new ModelError("primary_key must in propertys") if model_info.primary_key == undefined
    model_info["primary_key"] = "id" if model_info.primary_key == undefined
    for k, v of model_info
      @[k] = v

  new:(p)->
    keys = []
    vals = []

    for k, v of p
      #v = '"' + v + '"' if typeof v == "string"
      k = "'#{k}'" if k in special_field
      keys.push k
      vals.push v

    sql = "INSERT INTO #{@_name}(#{keys.join(",")})VALUES(#{("?" for i in vals).join(",")})"
    console.log db.prepare sql
    console.log vals
    db.run sql,vals, (err, ret)->
      if err
        if err.code == "SQLITE_CONSTRAINT"
          throw new ModelError "Table #{@_name} has a Constraint ModelError:\n #{vals}"
        else
          throw new ModelError err.message

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

User = new BaseModel "user", 
  primary_key : "id"

User.set
  id: 1
  email:"soddyque@gg.com"
  create: (new Date).getTime()

User.del 1
    

model = module.exports =
  User : new BaseModel "user"
  Content : new BaseModel "content",
    primary_key : "path"
  Comment : new BaseModel "comment"



