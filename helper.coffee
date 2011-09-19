# Helper of BanaJs
# author: dreampuf(soddyque@gmail.com)

assert = require "assert"
crypto = require "crypto"


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
    
    

if require.main == module #Unit Test
  do ()-> #sha1
    assert.equal (helper.sha1 "soddy"), "65afec57cb15cfd8eeb080daaa9e538aa8f85469", "sha1 Error"

  do ()-> #rand
    assert.notEqual (helper.rand 5 for i in [0..5]), (helper.rand 5 for i in [0..5])
    for i in [0..10]
      assert.ok 5 <= helper.rand(5, 10) < 10 , "#{_ref} don't in [5,10)"

  do ()-> #randstr
    assert.notEqual (helper.randstr 10), (helper.randstr 10)
    



