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
    res.render "admin/login"

  app.post "#{ admin_path }/logout/", admin_validate, (req, res)->
    req.session.admin = undefined
    res.redirect "/"

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
    if req.params.path
      path = req.params.path
      model.Content.get
        path:path
      , (rows)->
        if rows.length > 0
          res.render "admin/edit",
            menu: admin_menu
            content: rows[0]
            format: true
    else
      res.render "admin/edit",
        menu: admin_menu
        format: true

  app.post "#{admin_path}/edit/(:path)?", admin_validate, (req, res)->
    path = req.params.path
    pd = req.body
    if path
      model.Content.get
        path:path
      , (rows)->
        if rows.length > 0
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
    else
      model.Content.new
        path: helper.randstr 5
        title: pd.title
        body: pd.content
        create: (new Date).getTime()
      , (ret)->
        res.redirect "#{admin_path}/"

