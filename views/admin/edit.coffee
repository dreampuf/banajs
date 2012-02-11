@title = "文章编辑"
h2 @title


link rel: 'stylesheet', href: '/js/mup/style.css', media:'all'
link rel: 'stylesheet', href: '/js/mup/set_style.css', media:'all'
script src: "/js/mup/jquery.markitup.js"
script src: "/js/mup/set.js"
script src: "/js/fu/fileuploader.js"
link rel: 'stylesheet', href: '/js/fu/fileuploader.css', media:'all'
style -> """
#ct { overflow-y: visible; } 
.fileupdash {
  width: 100%; 
  height:105px; 
  border: 3px dashed #E5E5E5; 
  text-align: center;
}
"""
script -> """
var admin_path = "#{@admin_path}";
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
    dct = $ "#ct"
    dct.markItUp(mySettings)
    up = new qq.FileUploader
      element: document.getElementById "fileup_show"
      action: "#{admin_path}/upfile/"
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
  #li ->
  #  p "Title:"
  #  input type:"text", name:"title" , value: if @content then @content.title else ""
  div ->
    textarea id:"ct", name:"content", rows:20, cols:30, (if @content then "#{@content.content}" else "")
  
  div id:"fileup", ->
    div id:"fileup_show", ->
      
      ul id:"fileupls", ->
        li "Asdasd"

  input type:"submit", value:"提交"
