# BlogRoute of BanaJs
# author: dreampuf(soddyque@gmail.com)

utils = require "util"
Path = require "path"
md = require("node-markdown").Markdown
config = require "../config"
model = require "../model"
Content = model.Content
helper = require "../helper"

class BlogError extends Error
  constructor: (@message="Error", @statuscode=404)->
    @name = "BlogError"
    Error.call @name
    Error.captureStackTrace @, arguments.callee
    @

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
  app.get "/favicon.ico", (req, res)->
    res.sendfile "public/img/favicon.ico"

  app.get "/", (req, res)->
    cs = Content.sort_by_create true
    menu = []
    for i in cs
      if not i.content_html
        ct = md(i.content)
        [i.content_html, i.content_outline] = helper.converthtml ct
      i.ds = helper.dateds i.create
      if i.content_outline
        menu = menu.concat i.content_outline

    res.render "index",
      cs: cs
      menu: menu
      format: true

  app.get "/about/", (req, res)->
    res.render "about",
      layout: false

  app.get "/feed/", (req, res)->
    cs = Content.db

    last_update = Math.max.apply(Math, (i.modify for i in cs))
    _ = new Date
    _.setTime(last_update)
    last_update = _.toISOString()

    entrys = (i for i in cs)
    for i in cs
      i.content_feed = helper.html_escape(i.content_html)
      i.modify_feed = helper.int2date(i.modify).toISOString()

    res.contentType "atom"

    res.render "feed",
      layout: false
      entrys: entrys
      last_update: last_update

  app.get "/upfile/:path", (req, res)->
    fullpath = "#{config.upfile_dir}/#{req.params.path}"
    Path.exists fullpath, (exists)->
      if exists
        (if helper.ispic(fullpath) then res.sendfile else res.attachment)(fullpath)
      else
        res.end()

  app.get "/*", (req, res)->
    path = req.params[0]
    i = Content.get path:path
    if i is undefined
      console.log "Not Find '#{ path }'"
      return res.end()

    #ct = md(i.content)
    if not i.content_html
      ct = md(i.content)
      [i.content_html, i.content_outline] = helper.converthtml ct
    i.ds = helper.dateds i.create
    res.render "view",
      i: i
      menu: i.content_outline or []
