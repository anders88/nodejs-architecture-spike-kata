querystring = require('querystring')
url = require('url')
Person = require('./person').Person

exports.process = (req,res) ->
  parsed_url = url.parse(req.url,true)
  if (req.method == 'POST')
    create_person(req,res)  
  else if (parsed_url.pathname == "/person/list.html")
    res.writeHead(200, 'Content-Type':'text/html')
    res.end(display_search_form(parsed_url.query))
  else if (req.url == "/person/create.html")
    res.writeHead(200, 'Content-Type':'text/html')
    res.end(display_create_form())
  else
    res.writeHead(200, 'Content-Type':'text/html')
    res.end(display_menu())
    


class InmemoryPersonDao
  constructor : () -> @people = []
  create_person : (person) -> @people.push(person)
  find_people : (name_query) -> @people

personDao = new InmemoryPersonDao()

  
exports.setPersonDao = (newPersonDao) -> personDao = newPersonDao

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

display_search_form = (params) ->
  people = personDao.find_people(params.name_query)
  """  
          <form method="get">
          <input type="text" name="name_query" value="#{params.name_query ? ''}"/>
          <input type="submit" value="Find people"/>
          </form>
          <ul id="results">
            #{people.map((person) -> "<li>#{person.name}</li>")}
          </ul>
  """

create_person = (req,res) ->
  data = ""
  req.on("data", (chunk) -> data += chunk)
  req.on "end", () -> 
    personDao.create_person(new Person(querystring.parse(data).full_name))
    res.setHeader("Location", "/")
    res.statusCode = 301
    res.end()
