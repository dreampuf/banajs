# Admin Route of BanaJs
# author: dreampuf(soddyque@gmail.com)

utils = require "util"
model = require "../model"
helper = require "../helper"

class AdminError extends Error
  constructor: (@message="Error", @statuscode=400)->
    @name = "AdminError"
    Error.call @name
    Error.captureStackTrace @, arguments.callee
    @


route = module.exports = (app)->
  admin_path = app.admin_path
  admin_menu = [{
    text: "管理"
    href: "#"
    items: [{
      text: "添加"
      href: "#{ admin_path }/edit/"
    },{
      text: "登出"
      href: "#{ admin_path }/logout/"
    }]
  }]
  admin_validate = (req, res, next)->
    console.log req.session.admin
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
    res.render "admin/login"

  app.post "#{admin_path}/login/", (req, res)->
    email= req.body.email
    pwd = req.body.pwd
    model.User.check email, helper.sha1(pwd), (ok)->
      if ok
        req.session.admin = ok[0]
        res.redirect "#{admin_path}/"
      else
        res.redirect "#{admin_path}/login/"

  app.get "#{admin_path}/", admin_validate, (req, res)->
    model.Content.get (rows)->
      res.render "admin/admin",
        menu: admin_menu
        ls: rows
        admin_path: admin_path
        format: true

  app.get "#{admin_path}/edit/(:path)?", admin_validate, (req, res)->
    res.render "admin/edit",
      menu: admin_menu
      format: true

  app.post "#{admin_path}/edit/(:path)?", admin_validate, (req, res)->
    pd = req.body
    model.Content.new
      path: helper.randstr 5
      title: pd.title
      body: pd.content
      create: (new Date).getTime()
    , (ret)->
      console.log ret
      res.redirect "#{admin_path}/"

