# Helper of BanaJs
# author: dreampuf(soddyque@gmail.com)

assert = require "assert"
crypto = require "crypto"
libxml = require "libxmljs"


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
        
    
if require.main == module #Unit Test
  do ()-> #converthtml
    console.log helper.converthtml """<h1>简介</h1>
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
    
