# BlogRoute of BanaJs
# author: dreampuf(soddyque@gmail.com)

utils = require "util"
Path = require "path"
md = require("node-markdown").Markdown
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
  upfile_path = app.upfile_path
  app.get "/favicon.ico", (req, res)->
    res.sendfile "public/img/favicon.ico"

  app.get "/", (req, res)->
    cs = Content.sort_by_create true
    menu = []
    for i in cs
      ct = md(i.content)
      [ct, amenu] = helper.converthtml ct
      i.html = ct
      i.ds = helper.dateds i.create
      menu = menu.concat amenu

    res.render "index",
      cs: cs
      menu: menu
      format: true


  app.get "/about/", (req, res)->
    res.render "about",
      layout: false

  app.get "/feed/", (req, res)->
    cs = Content.db

    last_update = Math.max.apply(Math, [i.modify for i in cs])
    _ = new Date
    _.setTime(last_update)
    last_update = _.toISOString()

    entrys = ["""
    <entry>
        <link href="http://huangx.in/#{ i.path }"/>
        <id>http://huangx.in/#{ i.path }</id>
        <title>#{ i.title }</title>
        <content type="html">    
        #{ helper.html_escape(md(i.content)) }
        </content>
        <author>
            <name>Dreampuf</name>
        </author>
        <updated>#{ helper.int2date(i.modify).toISOString() }</updated>
    </entry>""" for i in cs]

    output = """
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="zh-cn" xml:base="http://huangx.in">
    <title>Bana</title>
    <subtitle>A programmer's self-learning</subtitle>
    <id></id>
    <link href="http://huangx.in" rel="self"/>
    <link href="http://huangx.in" rel="alternate" type="text/html"/>
    <link rel="hub" href="http://blogsearch.google.com/ping/RPC2"/>
    <link rel="hub" href="http://rpc.pingomatic.com/"/>
    <link rel="hub" href="http://blogsearch.google.com/ping/RPC2"/>
    <link rel="hub" href="http://ping.baidu.com/ping/RPC2"/>
    <updated>#{ last_update }</updated>
    <author>
        <name>Dreampuf</name>
    </author>
    #{ entrys.join "" }
</feed>
"""
    res.end output

  app.get "/upfile/:path", (req, res)->
    fullpath = "#{upfile_path}/#{req.params.path}"
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

    ct = md(i.content)
    [ct, amenu] = helper.converthtml ct
    i.html = ct
    i.ds = helper.dateds i.create
    res.render "view",
      i: i
      menu: amenu
