@title = "注册"

h1 @title

p "每一个ID,都是一段美好的姻缘"
form method:'POST',->
  ul ->
    li ->
      p "邮箱:"
      input name:'email',type:'text'
    li ->
      p "昵称:"
      input name:'nickname',type:'text'
    li ->
      p "密码:"
      input name:'password',type:'password'
    li ->
      p "确认密码:"
      input name:'repassword',type:'password'

  button id:"submit",class:"btn primary", -> span -> span "注册"
  button class:"btn",-> span -> span "取消"

coffeescript ->
  $("buttons#submit ").click (e)->
    $("form").submit()
    false

  $("button:contains('取消')").click (e)->
    window.location = window.location.origin
    false
