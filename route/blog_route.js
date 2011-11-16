(function() {
  var hard_menu, helper, md, model, route, utils;
  utils = require("util");
  md = require("node-markdown").Markdown;
  model = require("../model");
  helper = require("../helper");
  hard_menu = [
    {
      text: "三四岁",
      href: "/",
      items: [
        {
          text: "添加",
          href: "/edit/"
        }, {
          text: "登出",
          href: "/logout/"
        }
      ]
    }
  ];
  route = module.exports = function(app) {
    return app.get("/", function(req, res) {
      return model.Content.get(function(rows) {
        var amenu, ct, i, menu, _i, _len, _ref;
        menu = [];
        for (_i = 0, _len = rows.length; _i < _len; _i++) {
          i = rows[_i];
          ct = md(i.body);
          _ref = helper.converthtml(ct), ct = _ref[0], amenu = _ref[1];
          i.content = ct;
          menu = menu.concat(amenu);
        }
        return res.render("index", {
          ls: rows,
          menu: menu,
          format: true
        });
      });
    });
  };
}).call(this);
