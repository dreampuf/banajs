form method:"post", ->
  ul ->
    li ->
      p -> "Email:"
      input name:"email", type:"text"
    li ->
      p -> "Password:"
      input name:"pwd", type:"password"

  input type:"submit", value:"提交"
