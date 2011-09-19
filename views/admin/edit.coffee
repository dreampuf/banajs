
form method:"POST", ->
  li ->
    p "Title:"
    input type:"text", name:"title"
  li ->
    p "Content:"
    textarea name:"content", rows:20, cols:30

  input type:"submit", value:"提交"
