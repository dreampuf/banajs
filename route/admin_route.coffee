# Admin Route of BanaJs
# author: dreampuf(soddyque@gmail.com)

utils = require "util"
assert = require "assert"
querystring = require "querystring"
url = require "url"
fs = require "fs"
Path = require "path"
md = require("node-markdown").Markdown
formidable = require "formidable"
model = require "../model"
form = require "../form"
rule = form.rule
helper = require "../helper"
exec = require('child_process').exec

User = model.User
Content = model.Content

class AdminError extends Error
  constructor: (@message="Error", @statuscode=500)->
    @name = "AdminError"
    Error.call @name
    Error.captureStackTrace @, arguments.callee
    @

form_reg = form.Form("Reg")
             .field("email", "Email", rule.email())
             .field("nickname", "Nickname", rule.required())
             .field("password", "Password", rule.required())
             .field("repassword", "RePassword", rule.equal("password"))

form_login = form.Form("Login")
             .field("email", "Email", rule.email())
             .field("pwd", "Password", rule.required())

route = module.exports = (app)->
  admin_menu = [{
    text: "管理"
    href: "/admin/"
    items: [{
      text: "样式管理"
      href: "/admin/style/"
    },{
      text: "添加"
      href: "/admin/edit/"
    },{
      text: "登出"
      href: "/admin/logout/"
      method: "POST"
    }]
  }]
  admin_validate = (req, res, next)->
    #console.log req.path, req.session.admin is undefined
    if req.session.admin?
      next()
    else
      next new AdminError("refuse access")

  app.error (err, req, res, next)->
    if err instanceof AdminError
      #console.log req
      #referer = req.header "referer"
      rurl = "/admin/login/"
      data = {}
      if req.url
        data["c"] = url.parse(req.url).pathname
      if req.body
        data["POST"] = querystring.stringify(req.body)
      else if req.query
        data["GET"] = querystring.stringify(req.query)
      if data["c"]
        rurl += "?#{ querystring.stringify data }"
        
      res.redirect rurl
      #res.render "admin/error",
      #  error: err
      #  status: err.statuscode
    else
      next(err)


  app.get "/admin/login/", (req, res)->
    if User.db.length == 0
      return res.redirect "/admin/reg/"

    res.render "admin/login"

  app.post "/admin/login/", (req, res)->
    email= req.body.email
    pwd = req.body.pwd
    ret = model.User.check email, helper.sha1(pwd)

    if ret
      req.session.admin = ret

    if req.xhr #登录前后续处理
      res.json if ret then true else false
    else
      res.redirect if ret then "/admin/" else
        "/admin/login/#ValidateError"

  app.post "/admin/logout/", admin_validate, (req, res)->
    delete req.session.admin
    res.redirect "/"

  app.get "/admin/reg/", (req, res)->
    if User.db.length != 0
      throw new AdminError("You had a Admin User")
    res.render "admin/reg"

  app.post "/admin/reg/", (req, res)->
    form = form_reg.validate req.body
    if !form.isValid()
      return res.send form.errors(), 400
    if User.db.length != 0
      throw new AdminError("You had a Admin User")

    u = form.data
    u.password = helper.sha1 u.password
    delete u.repassword
    User.put u, ()->
      res.redirect "/admin/login/"

  app.get "/admin/", admin_validate, (req, res)->
    contents = Content.db
    res.render "admin/admin",
      menu: admin_menu
      ls: contents
      format: true

  app.get "/admin/edit/(:path)?", admin_validate, (req, res)->
    path = req.params.path
    if path is undefined #new content
      res.render "admin/edit",
        menu: admin_menu
        format: true
      return

    path = path | 0
    pd = (i for i in Content.db when path == i.id)[0]
    if not pd
      throw new AdminError("invalid content")
    
    res.render "admin/edit",
      menu: admin_menu
      content: pd
      format: true

  app.post "/admin/edit/(:path)?", admin_validate, (req, res)->
    path = req.params.path | 0
    pd = req.body
    ctime = (new Date).getTime()
    if not path #new content
      ct_html = md pd.content
      [ct_html, ct_menu] = helper.converthtml ct_html
      helper.update pd,
        title: helper.fetch_title ct_html
        create: ctime
        modify: ctime
        author: req.session.admin.email
        content_html: ct_html
        content_outline: ct_menu
        view: 0

    else #modify content
      opd = (i for i in Content.db when path == i.id)[0]
      if not opd
        throw new AdminError("invalid content")
       
      ct_html = md pd.content
      [ct_html, ct_menu] = helper.converthtml ct_html
      helper.update opd,
        title: helper.fetch_title ct_html
        content: pd.content
        content_html: ct_html
        content_outline: ct_menu
        modify: ctime
      pd = opd
    
    if not pd.id
      helper.update pd,
        id : Content.id()

    if not pd.title
      pd.title = pd.id
        
    helper.net_mt pd.title, (title_en)->
      ctime = new Date
      ctime.setTime pd.create
      #TODO more userful
      pd.path = "#{ctime.getFullYear()}/#{ctime.getMonth()+1}/#{helper.title_url title_en}.html"
      Content.put pd
      res.redirect "/admin/"
  
  app.post "/admin/upfile/", admin_validate, (req, res)->
    #f = new formidable.IncomingForm()
    #files = []
    #f.uploadDid = "../upfile/"
    #f
    #  .on "file", (file)->
    #    console.log file
    #  .on "end", ()->
    #    res.end()
    #f.parse req
    if req.xhr and req.header("Content-Type") == "application/octet-stream"
      chunks = []
      size = 0
      req.on "data", (chunk)->
        chunks.push chunk
        size += chunk.length
      req.on "end", ()->
        data = null
        switch chunks.length
          when 0 then data = new Buffer(0)
          when 1 then data = chunks[0]
          else
            data = new Buffer(size)
            pos = 0
            for chunk in chunks
              chunk.copy data, pos
              pos += chunk.length

        #Save The File
        f = req.query.file
        [_, basename, extendname] = f.split /^(.*?)(.[^.]*)?$/ig
        seq = ""
        while Path.existsSync "#{ config.upfile_dir }/#{ basename + seq + extendname}"
          seq = (seq|0)+1 + ""
        target_path = "#{ basename + seq + extendname}"
        fs.writeFile "#{ config.upfile_dir }/#{target_path}", data, (err)->
          if err
            console.log "upfile error: ", err
            res.json error: err.message
          else
            res.json success: true, url: target_path

  editable = [".js", "css", "fee", "tml"]
  app.get "/admin/style/", admin_validate, (req, res)->
    file = req.param("file") or "public/css/style.css"
    helper.walk "public", (err, statics)->
      console.log err if err
      helper.walk "views", (err, files)->
        console.log err if err
        fs.readFile file, "utf-8", (err, data)->
          if err
            console.log "style edite error:", err
            res.redirect "/admin"
          else
            res.render "admin/style",
              files: (i for i in statics.concat(files) when i[-3..] in editable).concat(["config.coffee"])
              file: file
              style: data

  app.post "/admin/style/", admin_validate, (req, res)->
    file = req.param("file")
    code = req.param("code")
    return res.redirect("/admin/") if not code.trim() or not file.trim() or file[-3..] not in editable
    fs.writeFile file, code.replace(/\cM/g, "").replace("\r\n", "\n"), (err)->
      console.log err if err
      if file[-3..] == "fee"
        exec "forever list", (err, stdout, stderr)->
          console.log arguments

      res.redirect("/admin/")
