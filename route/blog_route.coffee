# BlogRoute of BanaJs
# author: dreampuf(soddyque@gmail.com)

utils = require "util"
md = require("node-markdown").Markdown
model = require "../model"
helper = require "../helper"

route = module.exports = (app)->
  app.get "/", (req, res)->
    model.Content.get (rows)->
      for i in rows
        i.content = md(i.body)
      res.render "index", 
        ls: rows
        format: true
        nav_ul:
          [
            [
              href:"#array"
              text:"数组"
            , href:"#ssss"
            text:"集合"
            ],[
              href:"#arraysdsd"
              text:"数列"
            , href:"#11243"
            text:"集体"
            ]
          ]

