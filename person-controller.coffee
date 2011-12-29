exports.process = (req,res) ->
  res.writeHead(200, 'Content-Type':'text/html')
  if (req.url == "/person/create.html")
    res.end(display_create_form())
  else
    res.end(display_menu())

display_menu = ->
  """
  <html>
    <head>
      <title>Person Database</title>
    </head>
    <body>
      <ul id="menu">
        <li><a href="person/create.html">Create person</a></li>
        <li><a href="person/list.html">Find people</a></li>
      </ul>
    </body>
  </html>
  """

display_create_form = ->
  """
          <form method="post">
          <input type="text" name="full_name" value=""/>
          <input type="submit" value="Create person"/>
          </form>
  """


