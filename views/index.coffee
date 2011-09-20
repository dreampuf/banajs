@title = "BanaJS"
h3 @title

ul ->
  for i in @ls
    li -> p "#{i.content}"
