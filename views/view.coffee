@title = "#{@i.title}"
h3 @title

article ->
  text "#{@i.html}"
  span class:"public-date", -> "发表于#{ @i.ds }"

  div id: "disqus_thread"
  script """
    var disqus_shortname = 'bana',
        disqus_identifier = '#{ @i.path }',
        disqus_developer = 1;

    (function() {
        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
        dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';
        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
    })(); """

