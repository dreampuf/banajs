(function() {
  var route;
  route = module.exports = function(app) {
    return app.get("/", function(req, res) {
      return res.render("index", {
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
  };
}).call(this);
