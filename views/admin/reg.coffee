@title = "初始化管理员帐号"

h2 @title

form method:"POST", ->
  li ->
    p "Email:"
    input type:"text", name:"email" , value: ""
  li ->
    p "Nickname:"
    input type:"text", name:"nickname" , value: ""
  li ->
    p "Password:"
    input type:"password", name:"password" , value: ""
  li ->
    p "RePassword:"
    input type:"password", name:"repassword" , value: ""

  input type:"submit", value:"提交"
