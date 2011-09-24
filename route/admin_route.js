(function() {
  var AdminError, helper, model, route, utils;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  utils = require("util");
  model = require("../model");
  helper = require("../helper");
  AdminError = (function() {
    __extends(AdminError, Error);
    function AdminError(message, statuscode) {
      this.message = message != null ? message : "Error";
      this.statuscode = statuscode != null ? statuscode : 400;
      this.name = "AdminError";
      Error.call(this.name);
      Error.captureStackTrace(this, arguments.callee);
      this;
    }
    return AdminError;
  })();
  route = module.exports = function(app) {
    var admin_menu, admin_path, admin_validate;
    admin_path = app.admin_path;
    admin_menu = [
      {
        text: "管理",
        href: "" + admin_path + "/",
        items: [
          {
            text: "添加",
            href: "" + admin_path + "/edit/"
          }, {
            text: "登出",
            href: "" + admin_path + "/logout/",
            method: "POST"
          }
        ]
      }
    ];
    admin_validate = function(req, res, next) {
      if (req.session.admin != null) {
        return next();
      } else {
        return next(new AdminError("refuse access"));
      }
    };
    app.error(function(err, req, res, next) {
      console.dir(err);
      if (err instanceof AdminError) {
        return res.redirect("" + admin_path + "/login/");
      } else {
        return next(err);
      }
    });
    app.get("" + admin_path + "/login/", function(req, res) {
      return res.render("admin/login");
    });
    app.post("" + admin_path + "/logout/", function(req, res) {
      req.session.admin = void 0;
      return res.redirect("/");
    });
    app.post("" + admin_path + "/login/", function(req, res) {
      var email, pwd;
      email = req.body.email;
      pwd = req.body.pwd;
      return model.User.check(email, helper.sha1(pwd), function(ok) {
        if (ok) {
          req.session.admin = ok[0];
          return res.redirect("" + admin_path + "/");
        } else {
          return res.redirect("" + admin_path + "/login/");
        }
      });
    });
    app.get("" + admin_path + "/", admin_validate, function(req, res) {
      return model.Content.get(function(rows) {
        return res.render("admin/admin", {
          menu: admin_menu,
          ls: rows,
          admin_path: admin_path,
          format: true
        });
      });
    });
    app.get("" + admin_path + "/edit/(:path)?", admin_validate, function(req, res) {
      var path;
      if (req.params.path) {
        path = req.params.path;
        return model.Content.get({
          path: path
        }, function(rows) {
          if (rows.length > 0) {
            return res.render("admin/edit", {
              menu: admin_menu,
              content: rows[0],
              format: true
            });
          }
        });
      } else {
        return res.render("admin/edit", {
          menu: admin_menu,
          format: true
        });
      }
    });
    return app.post("" + admin_path + "/edit/(:path)?", admin_validate, function(req, res) {
      var path, pd;
      path = req.params.path;
      pd = req.body;
      if (path) {
        return model.Content.get({
          path: path
        }, function(rows) {
          var ct;
          if (rows.length > 0) {
            ct = rows[0];
            ct.title = pd.title;
            ct.body = pd.content;
            return model.Content.set(ct, function(ret) {
              if (ret.changes === 1) {
                return res.redirect("" + admin_path + "/");
              } else {
                throw new AdminError("bad changes");
              }
            });
          } else {
            return model.Content["new"]({
              path: path,
              title: pd.title,
              body: pd.content,
              create: (new Date).getTime()
            }, function(ret) {
              return res.redirect("" + admin_path + "/");
            });
          }
        });
      } else {
        return model.Content["new"]({
          path: helper.randstr(5),
          title: pd.title,
          body: pd.content,
          create: (new Date).getTime()
        }, function(ret) {
          return res.redirect("" + admin_path + "/");
        });
      }
    });
  };
}).call(this);
