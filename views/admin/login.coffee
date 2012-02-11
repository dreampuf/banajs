form id:"login", method:"post", ->
  ul ->
    li ->
      p -> "Email:"
      input name:"email", type:"text"
    li ->
      p -> "Password:"
      input name:"pwd", type:"password"

  input type:"submit", value:"提交"

coffeescript ->
  $(document.body).keydown (e)->
    if e.keyCode == 13
      $("#login").submit()
  locs = location.search
  if locs
    c = location.getParameter "c"
    method = location.getParameter "method"
    reg = /\??(?:&?([^=]+)=([^&]+))/g
    ds = (matchs[1..] for i in [0..locs.match(reg).length] when (matchs = reg.exec locs) and
                                                                 matchs[1] not in ["c", "method"])
    if ds > 0
      f = $("<form action='#{ c }' method='#{ method }'></form>")
      for i in ds
        f.append "<input type='text' name='#{i[0]}' value='#{i[1]}'>"

      login_f = $("#login").submit (e)->
        e.preventDefault()
        f.submit()
        return false
