# Model of BanaJs
# author: dreampuf(soddyque@gmail.com)

Tiny = require('tiny')


Model = (model_name)->
  @name = "#{__dirname}/db/#{model_name}.tiny"
  @init()
  @

Model.id = (db, cb)->
  db.get "_id", (err, data)->
    if err #err unless db.get Can't find the object
      id = 0
    else
      id = data.val + 1

    db.set "_id", 
      val : id
      
    cb(id)

Model::init = ()->
  Tiny @name, (err, db)=>
    throw err if err
    @db = db

Model::get = (opt, cb)->
  Tiny @name, (err, db)->
    throw err if err

    db.get opt,(err, ret)->
      cb err, ret

Model::each = (cb)->
  Tiny @name, (err, db)->
    db.each cb

Model::set = (opt, cb)->
  Tiny @name, (err, db)->
    throw err if err

    Model.id db,(id)->
      db.set id + "", opt, ()->
        #console.log "OK"

Model::dump = ()->
  Tiny @name, (err, db)->
    db.dump true, (err)->
      console.log err if err

model = module.exports = 
  User: new Model("User")
  Test: ()->
      #console.log model.User
      #console.log model.User.db
    a = new Date
    for i in [1..10000]
      model.User.set
        name:("abcdefg"[Math.random()*7|0] for j in [1..10]).join("")
        age: Math.random()*100
        birth: new Date
    console.log new Date() - a

    model.User.get 10000, (err, ret)->
      console.log err, ret

    #for i in [0..10]
    #  model.User.get i, (err, ret)->
    #    console.log err, ret , i

    #model.User.each (user)->
    #  console.log user

    #console.log model.User.db, "DBD"

    ##Tiny "#{__dirname}/db/User", (err, db)->
    #  db.find({age:123},) (err, ret)->
    #    console.log ret
    #model.User.dump()

model.Test()

