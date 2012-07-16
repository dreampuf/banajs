doctype 'xml', (version:"1.0", encoding:"UTF-8")
feed xmlns: 'http://www.w3.org/2005/Atom', ->
  title @config.title
  subtitle @config.dsc
  link rel: 'alternate', type: 'text/html', href: @config.domain
  link rel: 'self', type: 'application/atom+xml', href: "#{@config.domain}feed/"
  link rel: 'hub', href: 'http://blogsearch.google.com/ping/RPC2'
  link rel: 'hub', href: 'http://rpc.pingomatic.com/'
  link rel: 'hub', href: 'http://ping.baidu.com/ping/RPC2'
  id @config.domain
  updated @last_update
  author ->
    name @config.author
  rights "Copyright © #{@config.copyright}"

  for i in @entrys
    entry ->
      link href: "#{@config.domain}#{i.path}"
      id "#{@config.domain}#{i.path}"
      title "#{ i.title }"
      content type:"html", "#{ i.content }"
      author ->
        name "#{ i.author }"
      updated "#{ i.modify }"
