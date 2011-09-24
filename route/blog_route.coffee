# BlogRoute of BanaJs
# author: dreampuf(soddyque@gmail.com)

utils = require "util"
md = require("node-markdown").Markdown
model = require "../model"
helper = require "../helper"

hard_menu = [{
    text: "三四岁"
    href: "/"
    items: [{
      text: "添加"
      href: "/edit/"
    },{
      text: "登出"
      href: "/logout/"
    }]
  }]

route = module.exports = (app)->
  app.get "/", (req, res)->
    model.Content.get (rows)->
      menu = []
      for i in rows
        ct = md(i.body)
        [ct, amenu] = helper.converthtml ct
        i.content = ct
        menu = menu.concat amenu

      res.render "index", 
        ls: rows
        menu: menu
        format: true
