h3 @config.title

section id: 'content', ->
  for i in @cs
    article ->
      text "#{i.content_html}"
      span class:"public-date", -> "发表于#{ i.ds }"
      span "|"
      span class:"public-url", ->
        a href:"#{i.path}#disqus_thread", "data-disqus-identifier":"#{i.path}", "原文地址"

coffeescript ->
  s = document.createElement 'script'
  s.async = true
  s.src = "http://#{@config.disqus}.disqus.com/count.js"
  (document.getElementsByTagName('HEAD')[0] or document.getElementsByTagName('BODY')[0]).appendChild(s)
