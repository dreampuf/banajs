@title = "文章管理"

h2 @title

ul ->
  for i in @ls
    li ->
      a href:"/admin/edit/#{i.id}/", "#{i.title}"
      a href:"/#{i.path}", class: "atv", target:"_blank", " O"
