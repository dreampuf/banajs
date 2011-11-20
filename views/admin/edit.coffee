@title = "文章编辑"
h2 @title


link rel: 'stylesheet', href: '/js/mup/style.css', media:'all'
link rel: 'stylesheet', href: '/js/mup/set_style.css', media:'all'
script src: "/js/mup/jquery.markitup.js"
script src: "/js/mup/set.js"

coffeescript ->
  $ ()->
    $("#ct").markItUp(mySettings)

form method:"POST", ->
  #li ->
  #  p "Title:"
  #  input type:"text", name:"title" , value: if @content then @content.title else ""
  li ->
    textarea id:"ct", name:"content", rows:20, cols:30, (if @content then "#{@content.content}" else "")

  input type:"submit", value:"提交"
