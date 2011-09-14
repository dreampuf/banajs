(function() {
  var AdminError, route, utils;
  utils = require("util");
  AdminError = function(msg, statuscode) {
    if (msg == null) {
      msg = "Error";
    }
    if (statuscode == null) {
      statuscode = 400;
    }
    this.message = msg;
    this.statuscode = statuscode;
    this.name = "AdminError";
    Error.call(this.name);
    Error.captureStackTrace(this, arguments.callee);
    return this;
  };
  utils.inherits(AdminError, Error);
  route = module.exports = function(app) {
    var admin_path, admin_validate;
    admin_path = app.admin_path;
    admin_validate = function(req, res, next) {
      if (req.admin != null) {
        return next();
      } else {
        return next(new AdminError("refuse access"));
      }
    };
    app.error(function(err, req, res, next) {
      console.log("asdasd", err);
      if (err instanceof AdminError) {
        return res.render("admin/error", {
          error: err,
          status: err.statuscode
        });
      } else {
        return next(err);
      }
    });
    app.get("" + admin_path + "/login/", function(req, res) {
      return res.render("admin/login");
    });
    app.post("" + admin_path + "/login/", function(req, res) {
      return res.redirect("/");
    });
    return app.get("" + admin_path + "/", admin_validate, function(req, res) {
      return res.render("admin", {
        format: true
      });
    });
  };
}).call(this);
