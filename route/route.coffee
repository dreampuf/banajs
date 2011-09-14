# Route of BanaJs
# author: dreampuf(soddyque@gmail.com)

route = module.exports = (app)->
  app.get "/", (req, res)->
    res.render "index", 
      format: true
      nav_ul:
        [
          [
            href:"#array"
            text:"数组"
          , href:"#ssss"
          text:"集合"
          ],[
            href:"#arraysdsd"
            text:"数列"
          , href:"#11243"
          text:"集体"
          ]
        ]
         
