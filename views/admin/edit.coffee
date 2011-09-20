@title = "文章编辑"
h2 @title

form method:"POST", ->
  li ->
    p "Title:"
    input type:"text", name:"title" , value: if @content then @content.title else ""
  li ->
    p "Content:"
    textarea name:"content", rows:20, cols:30, (if @content then "#{@content.body}" else "")

  input type:"submit", value:"提交"
