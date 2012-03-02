@title = "#{@i.title}"

section id: 'content', ->
  article ->
    text "#{@i.html}"
    span class:"public-date", -> "发表于#{ @i.ds }"


section ->
  div id: "disqus_thread"
script """
  var disqus_identifier = '#{ @i.path }',
      disqus_developer = 1;

  (function() {
      var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
      dsq.src = 'http://bana.disqus.com/embed.js';
      (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
  })(); """

