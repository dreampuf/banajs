@title = "BanaJS"
h3 @title

for i in @cs
  article ->
    text "#{i.html}"
    span class:"public-url", ->
      a href:"#{i.path}", "文章地址"
    span class:"public-date", -> "发表于#{ i.ds }"
