doctype 5
html ->
  head ->
    title if @title? then "#{@title}" else "Bana"
    meta charset: 'utf-8'
    meta(name: 'description', content: @description) if @description?
    link(rel: 'canonical', href: @canonical) if @canonical?
    link(href: '/feed/', ref:'alternate', title:'Bana', type:'application/atom+xml')
    link(href: '/feed/', ref:'alternate', title:'Bana', type:'application/rss+xml')

    #link rel: 'icon', href: '/favicon.png'
    link rel: 'stylesheet', href: '/css/style.css', media:'all'
    #link rel: 'stylesheet', href: '/css/print.css', media:'print'
    ie 'lt IE 9', ->
      script src: "/js/html5.js"
    #script src: "/js/jquery.min.js"
    script src: "http://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.7.min.js"

    #style '''
    #'''
    coffeescript ->
      $ ()->
        $("a[method='POST']").each (n, i)->
          $(i).click (e)->
            target = $(e.target)
            $("<form method='POST' action='#{ target.attr "href" }'></form>").submit()
            return false
        #this.dopost = (e)->
        #  console.log $(e).attr "href"
        #  return false
  body ->
    nav id: 'nav_main', ->
      div ->
        ul ->
          li -> a href: '/', title: 'Index', 'Index'

        a id: 'top', href: '#content', title: 'Back to top', '#top'
        a id: 'hide_menu', class: 'tablet', 'Hide Menu'

      if @menu?
        for i in @menu
          ul ->
            li ->
              h1 ->
                a href: i.href, ->
                  span "✎"
                  span "#{i.text}"
              for j in i.items
                if j.method == "POST"
                  li -> a href: j.href, method:"POST", "#{ j.text }"
                else
                  li -> a href: j.href, "#{ j.text }"



    nav id: 'nav_mobile', ->
      a id: 'nav_prev_section', href: '#', ->
        text 'prev section'
        span class: 'nav_section_name', 'section name'
      a id: 'nav_next_section', href: '#', ->
        text 'next section'
        span class: 'nav_section_name', 'section name'
      a id: 'show_menu', 'show menu'


    text @body

    footer ->
      p ->
        text "BanaJS"
        a href:"https://plus.google.com/109999639752347046237/about", "关于作者"
      script """
var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-5293693-3']);
_gaq.push(['_setDomainName', 'huangx.in']);
_gaq.push(['_trackPageview']);
(function() {
  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
  ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();"""
