p ->
  div style:'width:300px;'
  text @ct
  (span class:'ip', -> @ip) unless !@ip?
  text '&nbsp&nbsp'
  span class:'date', -> (new Date).toISOString()
