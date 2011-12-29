util = require('util')
querystring = require('querystring')
personweb = require('../person-controller')
htmlparser = require('htmlparser')
select = require('soupselect').select
Person = require('../person').Person

describe 'Person controller', ->

  parse_html = (html) ->
    handler = new htmlparser.DefaultHandler
    parser = new htmlparser.Parser(handler)
    parser.parseComplete(html)
    handler.dom
    
  res = 
    headers : {}
    writeHead : () ->
    end : (html) -> res.dom = parse_html(html)
    setHeader : (name,value) -> @headers[name] = value
  
  it "shows menu with links", ->
    personweb.process({method:'GET',url:'/'}, res)
    links = select(res.dom, "ul#menu li a")
    link_titles = links.map((n) -> n.children[0].data)
    expect(link_titles).toEqual ["Create person", "Find people"]
    
  it "shows create form", ->
    res.writeHead = () ->
    res.end = (html) -> res.dom = parse_html(html)
    personweb.process({method:'GET',url:'/person/create.html'}, res)
    expect(select(res.dom, 'form[method="post"] input[name="full_name"]')[0].attribs.type).toEqual("text")
    expect(select(res.dom, 'form[method="post"] input[type="submit"]')[0].attribs.value).toEqual("Create person")

  it "creates person", ->
    req =
      url : "/person/create.html"
      method : 'POST'
      callbacks : []
      on : (name,callback) -> @callbacks[name] = callback
    createdPerson = null
    personweb.setPersonDao({
      create_person : (person) -> createdPerson = person
    })
    personweb.process(req, res)
    req.callbacks["data"](querystring.stringify(full_name: "Darth Vader"))
    req.callbacks["end"]()
    expect(res.headers["Location"]).toEqual("/")
    expect(res.statusCode).toEqual(301)
    expect(createdPerson).toEqual(new Person("Darth Vader"))
    
  it "shows search form", ->
    personweb.setPersonDao({ find_people : () -> [] })
    personweb.process({method:'GET',url:'/person/list.html'}, res)
    expect(select(res.dom, 'form[method="get"] input[name="name_query"]')[0].attribs.value).toEqual("")
    expect(select(res.dom, 'form[method="get"] input[name="name_query"]')[0].attribs.type).toEqual("text")
    expect(select(res.dom, 'form[method="get"] input[type="submit"]')[0].attribs.value).toEqual("Find people")    
    
  it "searches for people", ->
    queriedName = null
    personweb.setPersonDao({
      find_people : (nameQuery) -> queriedName = nameQuery; []
    })
    params = querystring.stringify(name_query: "vader")
    personweb.process({method:'GET',url:"/person/list.html?#{params}"}, res)
    expect(queriedName).toEqual("vader")

  it "displays search result", ->
    personweb.setPersonDao({
      find_people : () -> [new Person("Anakin Skywalker"), new Person("Darth Vader")]
    })
    params = querystring.stringify(name_query: "whatever")
    personweb.process({method:'GET',url:"/person/list.html?#{params}"}, res)
    results = select(res.dom, '#results li').map((n) -> n.children[0].data)
    expect(results).toEqual ["Anakin Skywalker", "Darth Vader"]
    
  it "echoes search string", ->
    personweb.setPersonDao({ find_people : () -> [] })
    params = querystring.stringify(name_query: "vader")
    personweb.process({method:'GET',url:"/person/list.html?#{params}"}, res)
    expect(select(res.dom, 'form[method="get"] input[name="name_query"]')[0].attribs.value).toEqual("vader")
    