# Admin Route of BanaJs
# author: dreampuf(soddyque@gmail.com)

utils = require "util"
assert = require "assert"
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
             .field("password", "Password", rule.required())

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
    console.dir err
    if err instanceof AdminError
      res.redirect "#{admin_path}/login/"
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
    #TODO 进行登录处理
    email= req.body.email
    pwd = req.body.pwd
    ret = model.User.check email, helper.sha1(pwd)
    if ret
      req.session.admin = ret
      res.redirect "#{admin_path}/"
    else
      res.redirect "#{admin_path}/login/#ValidateError"

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
    if not req.params.path #new content
      res.render "admin/edit",
        menu: admin_menu
        format: true

      return

    path = req.params.path
    model.Content.get
      path:path
    , (rows)->
      if rows.length > 0
        res.render "admin/edit",
          menu: admin_menu
          content: rows[0]
          format: true

  app.post "#{admin_path}/edit/(:path)?", admin_validate, (req, res)->
    path = req.params.path
    pd = req.body
    ctime = (new Date).getTime()
    if not path #new content
      ct_html = md pd.content
      pd.title = helper.fetch_title ct_html
      pd.create = ctime
      pd.modify = ctime
      pd.author = req.session.admin.email
      console.log pd
      #Content.put
      #  id: Content.id()
      #  path: helper.randstr 5
      #  title: pd.title
      #  body: pd.content
      #  create: (new Date).getTime()
      #, (ret)->
      res.redirect "#{admin_path}/"

      return

      model.Content.get
        path:path
      , (rows)->
        if rows.length > 0 #modify
          ct = rows[0]
          ct.title = pd.title
          ct.body = pd.content
          model.Content.set ct,(ret)->
            if ret.changes == 1
              res.redirect "#{admin_path}/"
            else
              throw new AdminError("bad changes")
        else
          model.Content.new
            path: path
            title: pd.title
            body: pd.content
            create: (new Date).getTime()
          , (ret)->
            res.redirect "#{admin_path}/"

