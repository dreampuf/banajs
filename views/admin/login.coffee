form method:"post", ->
  ul ->
    li ->
      p -> "用户名:"
      input type:"text"
    li ->
      p -> "密码:"
      input type:"password"

  input type:"submit", value:"提交"
