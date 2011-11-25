@title = "BanaJS"
h3 @title

for i in @cs
  article ->
    text "#{i.html}"
    span class:"public-date", -> "发表于#{ i.ds }"
