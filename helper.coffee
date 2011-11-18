# Helper of BanaJs
# author: dreampuf(soddyque@gmail.com)

assert = require "assert"
crypto = require "crypto"
http = require "http"
https = require "https"
url = require "url"
md = require("node-markdown").Markdown
libxml = require "libxmljs"
request = require "request"


helper = module.exports = 
  sha1: (data, type="sha1")->
    allowtype = ["sha1", "md5", "sha256", "sha512"]
    throw new Error("type Must in #{allowtype} but then #{type}") if type not in allowtype
    sha1sum = crypto.createHash type
    sha1sum.update data
    sha1sum.digest "hex"

  rand: (min=10, max=min)->
    if min == max
      Math.random()*min | 0
    else
      assert.ok min < max, "min(#{min}) MUST less then max(#{max})"
      min + Math.random()*(max-min) | 0

  randstr: do ()->
    tmp = (String.fromCharCode i for i in [65..122] when i not in [91..96])
    tmplen = tmp.length
    (min=5, max=min)->
      if min == max
        (tmp[Math.random()*tmplen | 0] for i in [0..min]).join("")
      else
        assert.ok min < max, "min MUST less then max"
        (tmp[Math.random()*tmplen | 0] for i in [min..(min + helper.rand(max-min))]).join("")

  converthtml: do ()->
    """ 生成类似于rST的文档目录结构 """
    (html)->
      tr = libxml.parseHtmlString html
      fcd = tr.find "/html/body/*"
      tree = []
      push_node = (t, i) ->
        t.push
          tag : i.name()
          text : i.text()
          href : "##{i.text()}"
          items : []
      for i in fcd
        iname = i.name()
        if iname?[0] == "h"
          tlen =  if tree.length > 0 then tree.length - 1 else 0
          if tree[-1]?.tag == iname
            push_node tree, i
          else if tree[tlen]?.tag
            last = parseInt tree[tlen].tag[1..]
            now = parseInt iname[1..]
            if last < now
              push_node tree[tlen].items, i
            else
              push_node tree, i
          else
            push_node tree, i

          section = new libxml.Element tr, "section",
            id: i.text()
          header = new libxml.Element(tr, "header")
          section.addChild header
          nt = i.nextSibling()
          pt = i.parent()
          i.remove()
          header.addChild i
          if nt then nt.addPrevSibling section else pt.addChild section

      [((i.toString() for i in tr.find("/html/body/*")).join ""), tree]

  fetch_title : (html, len=20) ->
    doc = libxml.parseHtmlString html
    fcd = doc.find "//h1"
    if fcd.length > 0
      fcd[0].text()
    else
      nodes = doc.find "//*"
      ret = (i.text() for i in nodes).join("").replace(/\s+/g, "")
      if ret.length > len
        ret = "#{ ret[..len-3]}..."
      ret

  net_mt_google : do ()->
    re_ret = /"translatedText": "([\w\W]+)"/g
    (ct, source="zh-CN", target="en", cb=null)->
      if arguments.length == 2 and typeof(source) == "function"
        cb = source
        source = "zh-CN"
      if not cb
        throw new Error "callback function is null!"

      turl = url.format 
        host: "www.googleapis.com"
        protocol: "https:"
        pathname: "/language/translate/v2"
        methd: "GET"
        query:
          key: "AIzaSyD3_KyaIis7pklJsNXt_isG7QzkTYPmf2w"
          q: ct
          source: source
          target: target
          callback: "BANAJS"
          _: (new Date).getTime()

      do (cb)->
        request
          method: "GET"
          uri: turl
        , (err, res, body)->
          if err
            ret = ""
          else
            body = body[body.indexOf("(")+1..body.length-3]
            obj = JSON.parse body
            ret = obj.data?.translations?[0].translatedText
          cb ret

  net_mt: do ()->
    (ct, source="zh-CN", target="en", cb=null)->
      if arguments.length == 2 and typeof(source) == "function"
        cb = source
        source = "zh-CN"
      if not cb
        throw new Error "callback function is null!"

      turl = url.format
        host: "api.microsofttranslator.com"
        protocol: "http:"
        pathname: "/V2/Ajax.svc/Translate"
        methd: "GET"
        query:
          appid: "6D59EC9FB44063B2D9824487AF0DD071532E416D"
          text: ct
          from: source
          to: target
          _: (new Date).getTime()

      do (cb)->
        request
          method: "GET"
          uri: turl
        , (err, res, body)->
          cb body[2..body.length-2]

  parser_content : (body, cb)->
    ct_html = md body
    title = (helper.fetch_title ct_html) or ""
    ctime = new Date
    helper.net_mt title,(path)->
      if path
        path = path.toLowerCase().replace /[\s\W]+/g, "_"
      else
        #TODO maybe more fail in this convert
        path = "#{ctime.getYear()+1900}#{ctime.getMonth()+1}#{ctime.getDate()}"

      cb
        path: path
        title: title
        body: body
        create: ctime

  title_url : (title)->
    title.trim().toLowerCase().replace(/["'\.]/g, "").replace(/[-+]\s+/g, "_")
    
if require.main == module #Unit Test
  do ()-> #title_url
    console.log helper.title_url "The other day I and founder of Excite.com ..."
  do ()-> #parser content
    helper.parser_content """<h1>你好BanaJS</h1>
      <p>萨打算打算</p>
      <h2>开篇</h2>
      <p>aaaaaaaaaaaaa</p>
      """
    , (obj)->
      assert.equal "hello_banajs", obj.path

  do ()-> #net_mt
    #helper.net_mt_google "你好", (ret)->
    #  assert.equal ret, "Hello"

    helper.net_mt "今天天气真好,不是刮风就是下雨", (ret)->
      assert.equal ret, "Today the weather is really good, either windy or raining"

  do ()-> #fetch_title
    assert.equal helper.fetch_title("""<h1>ttt</h1>
      <p>asdasd</p>""")
    , "ttt"
    assert.equal helper.fetch_title("""<p>some other story</p>
      <h1>title</h1>""")
    , "title"

    assert.equal helper.fetch_title(md("""## asdasdad\r\nfsdafsadf\r\n\r\n## cccc\r\nsdfsadfsdfsadf"""))
    , "asdasdadfsdafsadfc..."

  do ()-> #converthtml
    assert.ok helper.converthtml """<h1>简介</h1>
      <p>萨打算打算</p>
      <h2>开篇</h2>
      <p>asdasdasd</p>
      <h3>测试</h3>
      <p>asdadasd</p>
      <h1>开始</h1>
      <h2>1</h2>
      <p>aaa</p>
      <h2>2</h2>
      <h2>3</h2>
      <h3>内容</h3>
      <p>aaaaaaaaaaaaa</p>
      """
  do ()-> #sha1
    assert.equal (helper.sha1 "soddy"), "65afec57cb15cfd8eeb080daaa9e538aa8f85469", "sha1 Error"

  do ()-> #rand
    assert.notEqual (helper.rand 5 for i in [0..5]), (helper.rand 5 for i in [0..5])
    for i in [0..10]
      assert.ok 5 <= helper.rand(5, 10) < 10 , "#{_ref} don't in [5,10)"

  do ()-> #randstr
    assert.notEqual (helper.randstr 10), (helper.randstr 10)
    
