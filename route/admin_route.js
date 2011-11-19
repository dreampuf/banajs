(function() {
  var AdminError, Content, User, assert, form, form_login, form_reg, helper, md, model, querystring, route, rule, url, utils;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  utils = require("util");
  assert = require("assert");
  querystring = require("querystring");
  url = require("url");
  md = require("node-markdown").Markdown;
  model = require("../model");
  form = require("../form");
  rule = form.rule;
  User = model.User;
  Content = model.Content;
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
  form_reg = form.Form("Reg").field("email", "Email", rule.email()).field("nickname", "Nickname", rule.required()).field("password", "Password", rule.required()).field("repassword", "RePassword", rule.equal("password"));
  form_login = form.Form("Login").field("email", "Email", rule.email()).field("pwd", "Password", rule.required());
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
      var rurl;
      console.dir(err);
      if (err instanceof AdminError) {
        rurl = "" + admin_path + "/login/?c=" + (url.parse(req.header("referer")).pathname);
        if (req.body) {
          rurl += "&method=POST&" + (querystring.stringify(req.body));
        } else if (req.query) {
          rurl += "&method=GET&" + (querystring.stringify(req.query));
        }
        return res.redirect(rurl);
      } else {
        return next(err);
      }
    });
    app.get("" + admin_path + "/login/", function(req, res) {
      if (User.db.length === 0) {
        return res.redirect("" + admin_path + "/reg/");
      }
      return res.render("admin/login");
    });
    app.post("" + admin_path + "/login/", function(req, res) {
      var email, pwd, ret;
      email = req.body.email;
      pwd = req.body.pwd;
      ret = model.User.check(email, helper.sha1(pwd));
      if (ret) {
        req.session.admin = ret;
      }
      if (req.xhr) {
        return res.json(ret ? true : false);
      } else {
        return res.redirect(ret ? "" + admin_path + "/" : "" + admin_path + "/login/#ValidateError");
      }
    });
    app.post("" + admin_path + "/logout/", admin_validate, function(req, res) {
      delete req.session.admin;
      return res.redirect("/");
    });
    app.get("" + admin_path + "/reg/", function(req, res) {
      if (User.db.length !== 0) {
        throw new AdminError("You had a Admin User");
      }
      return res.render("admin/reg");
    });
    app.post("" + admin_path + "/reg/", function(req, res) {
      var u;
      form = form_reg.validate(req.body);
      if (!form.isValid()) {
        return res.send(form.errors(), 400);
      }
      if (User.db.length !== 0) {
        throw new AdminError("You had a Admin User");
      }
      u = form.data;
      u.password = helper.sha1(u.password);
      delete u.repassword;
      console.log(u);
      return User.put(u, function() {
        return res.redirect("" + admin_path + "/login/");
      });
    });
    app.get("" + admin_path + "/", admin_validate, function(req, res) {
      var contents;
      contents = Content.db;
      return res.render("admin/admin", {
        menu: admin_menu,
        ls: contents,
        admin_path: admin_path,
        format: true
      });
    });
    app.get("" + admin_path + "/edit/(:path)?", admin_validate, function(req, res) {
      var path;
      if (!req.params.path) {
        res.render("admin/edit", {
          menu: admin_menu,
          format: true
        });
        return;
      }
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
    });
    return app.post("" + admin_path + "/edit/(:path)?", admin_validate, function(req, res) {
      var ct_html, ctime, path, pd;
      path = req.params.path;
      pd = req.body;
      ctime = (new Date).getTime();
      if (!path) {
        ct_html = md(pd.content);
        helper.update(pd, {
          title: helper.fetch_title(ct_html),
          create: ctime,
          modify: ctime,
          author: req.session.admin.email
        });
        helper.net_mt(pd.title, function(title_en) {
          pd.path = title_en;
          console.log(pd);
          return res.redirect("" + admin_path + "/");
        });
        return;
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
      }
    });
  };
}).call(this);
