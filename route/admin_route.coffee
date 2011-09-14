# Admin Route of BanaJs
# author: dreampuf(soddyque@gmail.com)

utils = require("util")

AdminError = (msg="Error", statuscode=400)->
  @message = msg
  @statuscode = statuscode
  @name = "AdminError"
  Error.call @name
  Error.captureStackTrace @, arguments.callee
  @

utils.inherits AdminError, Error


route = module.exports = (app)->
  admin_path = app.admin_path
  admin_validate = (req, res, next)->
    if req.admin?
      next()
    else
      next(new AdminError("refuse access"))

  app.error (err, req, res, next)->
    console.log "asdasd", err
    if err instanceof AdminError
      res.render "admin/error",
        error: err
        status: err.statuscode
    else
      next(err)

  app.get "#{admin_path}/login/", (req, res)->
    res.render "admin/login"

  app.post "#{admin_path}/login/", (req, res)->
    res.redirect("/")

  app.get "#{admin_path}/", admin_validate, (req, res)->
    res.render "admin",
      format: true
