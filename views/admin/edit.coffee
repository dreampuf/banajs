@title = "文章编辑"
h2 @title


link rel: 'stylesheet', href: '/js/mup/style.css', media:'all'
link rel: 'stylesheet', href: '/js/mup/set_style.css', media:'all'
script src: "/js/mup/jquery.markitup.js"
script src: "/js/mup/set.js"
script src: "/js/fu/fileuploader.js"
script src: "/js/marked/marked.min.js"
link rel: 'stylesheet', href: '/js/fu/fileuploader.css', media:'all'
style -> """
#ct { overflow-y: visible; } 
.fileupdash {
  width: 100%; 
  height:105px; 
  border: 3px dashed #E5E5E5; 
  text-align: center;
}
#preview:hover {
  background-color: #777;
  cursor: pointer;
}
"""
coffeescript ->
  picext_mapping =
    png: 1
    jpg: 1
    jpge: 1
    gif: 1
    tiff: 1
    bmp: 1
    
  $ ()->
    marked.setOptions
      gfm: true
      pedantic: false
      sanitize: true
      highlight: (code, lang)->
        if lang == 'js'
          return javascriptHighlighter(code)
        code

    dct = $ "#ct"
    stage = $ "#stage"
    dct.markItUp(mySettings)
    #dct.on "keypress", (e)->
    #  console.log @value
    #  console.log marked(@value)
    up = new qq.FileUploader
      element: document.getElementById "fileup_show"
      action: "/admin/upfile/"
      onComplete: (id, name, resp)->
        tagl = "#{ if picext_mapping[name[-3..]] then "!" else "" }["
        tagr = "](/upfile/#{encodeURIComponent(resp.url)})"
        if up.getInProgress() > 0
          $.markItUp openWith: tagl + name + tagr + "\n"
        else
          $.markItUp openWith: tagl, closeWith: tagr, placeHolder: name
        li = $ up._getItemByFileId id
        li.click (e)->
          $.markItUp openWith: tagl, closeWith: tagr, placeHolder: name

    window.preview = preview = do ()->
      pre = $ "#preview"
      pre.toggle()
      pre.click (e)->
        preview()
      ()->
        pre.toggle()
        pre.html(marked(dct.val()))
        stage.toggle()

form method:"POST", ->
  #li ->
  #  p "Title:"
  #  input type:"text", name:"title" , value: if @content then @content.title else ""
  div id:"stage", ->
    textarea id:"ct", name:"content", rows:20, cols:30, (if @content then "#{@content.content}" else "")

  div id:"preview"
  
  div id:"fileup", ->
    div id:"fileup_show", ->
      
      ul id:"fileupls", ->
        li "Asdasd"

  input type:"submit", value:"提交"
