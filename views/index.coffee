@title = "BanaJS"
h3 @title

section id: 'content', ->
  for i in @cs
    article ->
      text "#{i.html}"
      span class:"public-date", -> "发表于#{ i.ds }"
      span "|"
      span class:"public-url", ->
        a href:"#{i.path}#disqus_thread", "data-disqus-identifier":"#{i.path}", "原文地址"

coffeescript ->
  s = document.createElement 'script'
  s.async = true
  s.src = 'http://bana.disqus.com/count.js'
  (document.getElementsByTagName('HEAD')[0] or document.getElementsByTagName('BODY')[0]).appendChild(s)
