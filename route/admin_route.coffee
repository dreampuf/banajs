# Admin Route of BanaJs
# author: dreampuf(soddyque@gmail.com)

utils = require "util"
assert = require "assert"
querystring = require "querystring"
url = require "url"
md = require("node-markdown").Markdown
model = require "../model"
form = require "../form"
rule = form.rule
User = model.User
Content = model.Content
helper = require "../helper"

class AdminError extends Error
  constructor: (@message="Error", @statuscode=400)->
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
  admin_path = app.admin_path
  admin_menu = [{
    text: "管理"
    href: "#{ admin_path }/"
    items: [{
      text: "添加"
      href: "#{ admin_path }/edit/"
    },{
      text: "登出"
      href: "#{ admin_path }/logout/"
      method: "POST"
    }]
  }]
  admin_validate = (req, res, next)->
    if req.session.admin?
      next()
    else
      next new AdminError("refuse access")

  app.error (err, req, res, next)->
    if err instanceof AdminError
      #console.log req
      #referer = req.header "referer"
      rurl = "#{admin_path}/login/"
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


  app.get "#{admin_path}/login/", (req, res)->
    if User.db.length == 0
      return res.redirect "#{ admin_path }/reg/"

    res.render "admin/login"

  app.post "#{admin_path}/login/", (req, res)->
    email= req.body.email
    pwd = req.body.pwd
    ret = model.User.check email, helper.sha1(pwd)

    if ret
      req.session.admin = ret

    if req.xhr #登录前后续处理
      res.json if ret then true else false
    else
      res.redirect if ret then "#{admin_path}/" else
        "#{admin_path}/login/#ValidateError"

  app.post "#{ admin_path }/logout/", admin_validate, (req, res)->
    delete req.session.admin
    res.redirect "/"

  app.get "#{ admin_path }/reg/", (req, res)->
    if User.db.length != 0
      throw new AdminError("You had a Admin User")
    res.render "admin/reg"

  app.post "#{ admin_path }/reg/", (req, res)->
    form = form_reg.validate req.body
    if !form.isValid()
      return res.send form.errors(), 400
    if User.db.length != 0
      throw new AdminError("You had a Admin User")

    u = form.data
    u.password = helper.sha1 u.password
    delete u.repassword
    console.log u
    User.put u, ()->
      res.redirect "#{ admin_path }/login/"

  app.get "#{admin_path}/", admin_validate, (req, res)->
    contents = Content.db
    res.render "admin/admin",
      menu: admin_menu
      ls: contents
      admin_path: admin_path
      format: true

  app.get "#{admin_path}/edit/(:path)?", admin_validate, (req, res)->
    path = req.params.path | 0
    if not path #new content
      res.render "admin/edit",
        menu: admin_menu
        format: true
      return

    console.log Content.db, path
    pd = (i for i in Content.db when path == i.id)[0]
    if not pd
      throw new AdminError("invalid content")
    
    res.render "admin/edit",
      menu: admin_menu
      content: pd
      format: true

  app.post "#{admin_path}/edit/(:path)?", admin_validate, (req, res)->
    path = req.params.path | 0
    pd = req.body
    ctime = (new Date).getTime()
    if not path #new content
      ct_html = md pd.content
      helper.update pd,
        title: helper.fetch_title ct_html
        create: ctime
        modify: ctime
        author: req.session.admin.email
        view: 0

    else #modify content
      opd = (i for i in Content.db when path == i.id)[0]
      if not opd
        throw new AdminError("invalid content")
       
      ct_html = md pd.content
      helper.update opd,
        title: helper.fetch_title ct_html
        content: pd.content
        modify: ctime
      pd = opd
      
    helper.net_mt pd.title, (title_en)->
      ctime = new Date
      ctime.setTime pd.create
      #TODO more userful
      pd.path = "#{ctime.getFullYear()}/#{ctime.getMonth()+1}/#{helper.title_url title_en}.html"
      if not pd.id
        helper.update pd,
          id : Content.id()
      Content.put pd
      res.redirect "#{admin_path}/"
