(function() {
  var helper, md, model, route, utils;
  utils = require("util");
  md = require("node-markdown").Markdown;
  model = require("../model");
  helper = require("../helper");
  route = module.exports = function(app) {
    return app.get("/", function(req, res) {
      return model.Content.get(function(rows) {
        var i, _i, _len;
        for (_i = 0, _len = rows.length; _i < _len; _i++) {
          i = rows[_i];
          i.content = md(i.body);
        }
        return res.render("index", {
          ls: rows,
          format: true,
          nav_ul: [
            [
              {
                href: "#array",
                text: "数组"
              }, {
                href: "#ssss",
                text: "集合"
              }
            ], [
              {
                href: "#arraysdsd",
                text: "数列"
              }, {
                href: "#11243",
                text: "集体"
              }
            ]
          ]
        });
      });
    });
  };
}).call(this);
