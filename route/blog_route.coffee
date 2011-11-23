# BlogRoute of BanaJs
# author: dreampuf(soddyque@gmail.com)

utils = require "util"
md = require("node-markdown").Markdown
model = require "../model"
Content = model.Content
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
    rows = Content.db
    menu = []
    for i in rows
      ct = md(i.content)
      [ct, amenu] = helper.converthtml ct
      i.html = ct
      menu = menu.concat amenu

    res.render "index",
      ls: rows
      menu: menu
      format: true
