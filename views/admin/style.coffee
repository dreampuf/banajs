title = "样式编辑"
h2 @title


#link rel: 'stylesheet', href: '/js/mup/style.css', media:'all'
#link rel: 'stylesheet', href: '/js/mup/set_style.css', media:'all'
#script src: "/js/mup/jquery.markitup.min.js"
#script src: "/js/mup/set.js"
script src: "/js/fu/fileuploader.min.js"
link rel: 'stylesheet', href: '/js/fu/fileuploader.css', media:'all'
#script src: "/js/jquery.autogrow.js"
script src: "/js/codemirror.min.js"
link rel: 'stylesheet', href: '/js/codemirror.css', media:'all'
style -> """
#ct { overflow-y: visible; } 
.fileupdash {
  width: 720px; 
  height:105px; 
  border: 3px dashed #E5E5E5; 
  text-align: center;
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
    dct = $ "#code"
    dct.css("bgcolor", "#FFF")
    cm = CodeMirror.fromTextArea dct[0],
      mode: "css"
      lineNumbers: true
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


form method:"POST", ->
  div ->
    textarea id:"code", name:"code", (if @style then "#{@style}" else "")
  
  div id:"fileup", ->
    div id:"fileup_show", ->
      
      ul id:"fileupls", ->
        li "Asdasd"

  input type:"submit", value:"提交"
