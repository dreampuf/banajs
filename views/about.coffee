doctype 5
html ->
  head ->
    meta charset:"utf-8"
    title "About Huangxin"
    script src:"/js/raphael.js"
    style -> """
html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed, 
figure, figcaption, footer, header, hgroup, 
menu, nav, output, ruby, section, summary,
time, mark, audio, video {
    margin: 0;
    padding: 0;
    border: 0;
    font-size: 100%;
    font: inherit;
    vertical-align: baseline;
}

article, aside, details, figcaption, figure, 
footer, header, hgroup, menu, nav, section {
    display: block;
}
body {
    line-height: 1;
}
ol, ul {
    list-style: none;
}
blockquote, q {
    quotes: none;
}
blockquote:before, blockquote:after,
q:before, q:after {
    content: '';
    content: none;
}

table {
    border-collapse: collapse;
    border-spacing: 0;
}


body {
    font-family: 'PT Sans', sans-serif;
    min-height: 600px;
    background: rgb(215, 215, 215);
    background: -webkit-gradient(radial, 50% 50%, 0, 50% 50%, 500, from(rgb(240, 240, 240)), to(rgb(190, 190, 190)));
    background: -webkit-radial-gradient(rgb(240, 240, 240), rgb(190, 190, 190));
    background:    -moz-radial-gradient(rgb(240, 240, 240), rgb(190, 190, 190));
    background:      -o-radial-gradient(rgb(240, 240, 240), rgb(190, 190, 190));
    background:         radial-gradient(rgb(240, 240, 240), rgb(190, 190, 190));
    -webkit-font-smoothing: antialiased;
}

b, strong { font-weight: bold }
i, em { font-style: italic}

a {
    color: inherit;
    text-decoration: none;
    padding: 0 0.1em;
    background: rgba(255,255,255,0.5);
    text-shadow: -1px -1px 2px rgba(100,100,100,0.9);
    border-radius: 0.2em;
    
    -webkit-transition: 0.5s;
    -moz-transition:    0.5s;
    -ms-transition:     0.5s;
    -o-transition:      0.5s;
    transition:         0.5s;
}

a:hover {
    background: rgba(255,255,255,1);
    text-shadow: -1px -1px 2px rgba(100,100,100,0.5);
}

body     { padding: 15px; }
#skillradar { float:right; }
#baseinfo { width: 200px; padding-top: 50px; padding-left: 10px;}
#baseinfo dd { padding-top: 3px;} 
.personal_experience { margin-top: 10px; }

"""
  body ->
    div id:"skillradar"
    div id:"baseinfo", ->
      dd ->
        span "姓名:"
        span "黄鑫"
      dd ->
        span "性别:"
        span "男"
      dd ->
        span "年龄:"
        span "24"
      dd ->
        span "专业:"
        span "软件工程"
      dd ->
        span "Email:"
        a id:"mailme", "Are you spam?"
    
    pre class: "personal_experience", """

Personal Repository: <a href="https://github.com/dreampuf/">https://github.com/dreampuf/</a>

Personal Slides:  <a href="http://www.slideshare.net/dreampuf/">http://www.slideshare.net/dreampuf/</a>

研究方向: <br />并行处理，喜欢使用（但不仅有）multiprocess进行多进程并行开发，知道锁的好处与麻烦点，不能抑制对加速比的追求。<br />数据挖掘，对于数据充满饥渴，爬虫，格式化，存储，检索，挖掘，应用。

2012.05~2012.09: 作为Scrum Master在团队中解决各项问题，已经进行了8个Sprint。

2012.08: 参加北大可视化学习班，进行为期一周的数据可视化学习。

2012.05: 负责果壳长微博生成优化。

2012.03~2012.04: UBB格式内容渲染为适合微博转发的组件。

2012.01~2012.02: 负责果壳网问答相关优化，@功能数据端开发。问答提问相似检索实现randing部分。

2011.11~2011.12: 负责果壳网问答开发项目.

2011.3~2011.10: 负责果壳网Python中间层实现.主要负责缓存系统维护.

2011.1~2011.2 :  负责果壳网v2前台个人主页模块.架构同上.

2010.12 : 果壳网v2后台CMS. Python + Django + Twisted + Postgresql + Memcaache + Ngnix 

2010.12 :果壳时间 青年谱系 测试系统(Python + Django +Postgresql + Memcache + Ngnix),随后的果壳网承接IBM宣传项目Watson机器人大赛答题测试,也是于此相同的架构.

2010.6~2010.7 微软之星大赛全国三等奖网站.(C# / Asp.net MVC 2 + Microsoft Unity 2 + EntityFrameWork) : 作为组长负责整体系统架构，以及代码编写。

2009.11~2010.4 eWindow网站制作(Java / Structs2 + Hibernate) : 实践Java开发环境,项目包括三个小组,我负责前台组的页面脚本(JavaScript / Ext )编写。

2009.11 参加湖南省冬季技能大赛,获得软件应用二等奖. 同时期参加ACM个人斩获2题,不敌题牛被淘汰.
    """

    coffeescript ->
      class Radar
        constructor: (@el, ds)->
          @dslen = 0
          @ds = []
          max = 0
          for k, v of ds
            @dslen++
            @ds.push [k, v]
            max = v if max < v
          @dmax = max
      
        draw:()->
          @draw_bg()
      
        draw_bg: ()->
          el = @el
          ds = @ds
          dslen = @dslen
          dmax = @dmax
          width = height = 320
          paper = Raphael el, width+80, height
      
          cx = width/2 + 40
          cy = height/2
          r = width*0.45
          times = 7 #if r > 200 then 10 else 6
          for i in [1..times]
            c = paper.circle cx, cy, r*i/times
            c.attr stroke:"#EEE"
      
          grah_path_end = undefined
          grah_path = []
          radian_rate = 2 * Math.PI / 360
          for i in [0...dslen]
            angle = (360*i/dslen - 90) % 360
            rd = angle*radian_rate
            ty = r * (Math.sin rd)
            tx = r * (Math.cos rd)
            l = paper.path "M#{cx},#{cy}l#{tx},#{ty}"
            l.attr stroke: "#FEF"
      
            [k, v] = ds[i]
            ew = 14
            dx = if tx>0 then 1 else -1
            dy = if ty>0 then 1 else -1
            dr = v/dmax
            text = paper.text cx+tx, cy+ty, k
            #dd = Math.sqrt(Math.pow(text.attr("width"), 2) + Math.pow(text.attr("height"), 2))
            text.attr
              "font-size": 14
              "font-weight": 2
              #"x": cx+tx+dd*dx
              #"y": cy+ty+dd*dy
            
            if i == 0
              grah_path.push "M#{cx+tx*dr},#{cy+ty*dr}"
              grah_path.push "L#{cx+tx*dr},#{cy+ty*dr}z"
            else
              grah_path.splice -1, 0, "L#{cx+tx*dr},#{cy+ty*dr}"
      
          grah = paper.path grah_path.join ""
          grah.attr
            fill: "#F0F"
            "fill-opacity": .5
            stroke: "#F0F"
            "stroke-width": 0
            "stroke-opacity": .5
      
          0
      #
      rg = new Radar document.getElementById("skillradar"),
        "Csharp": 45
        "JavaScript": 80
        "Python": 99
        "Algorithm": 50
        "Concurrent": 50
        "Mining": 20
        "Visualization": 10
      rg.draw()
      

      mailme = document.getElementById "mailme"
      my_mail = "soddyque" + "@" + "gmail.com"
      mailme.innerText = my_mail
      mailme.href = "mailto:" + my_mail
      `var _gaq = _gaq || [];_gaq.push(['_setAccount', 'UA-5293693-3']);_gaq.push(['_setDomainName', 'huangx.in']);_gaq.push(['_trackPageview']);(function() { var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true; ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js'; var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s); })();`
      null
