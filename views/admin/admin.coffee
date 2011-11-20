@title = "文章管理"

h2 @title

ul ->
  for i in @ls
    li -> a href:"#{@admin_path}/edit/#{i.id}", "#{i.title}"
