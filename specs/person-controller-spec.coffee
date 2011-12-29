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
    
  req = new Object()
  res = new Object()
  
  it "shows menu with links", ->
    dom = null
    res.writeHead = () ->
    res.end = (html) ->
      dom = parse_html(html)
    personweb.process({method:'GET',url:'/'}, res)
    links = select(dom, "ul#menu li a")
    link_titles = links.map((n) -> n.children[0].data)
    expect(link_titles).toEqual ["Create person", "Find people"]
    
  it "shows create form", ->
    dom = null
    res.writeHead = () ->
    res.end = (html) ->
      dom = parse_html(html)
    personweb.process({method:'GET',url:'/person/create.html'}, res)
    expect(select(dom, 'form[method="post"] input[name="full_name"]')[0].attribs.type).toEqual("text")
    expect(select(dom, 'form[method="post"] input[type="submit"]')[0].attribs.value).toEqual("Create person")

  it "creates person", ->
    headers = {}
    res.setHeader = (name,value) ->
      headers[name] = value
    req.url = "/person/create.html"
    req.method = 'POST'
    req.callbacks = []
    req.on = (name,callback) ->
      req.callbacks[name] = callback
    createdPerson = null
    personweb.setPersonDao({
      create_person : (person) ->
        createdPerson = person
    })
    personweb.process(req, res)
    parameters = querystring.stringify(full_name: "Darth Vader")
    req.callbacks["data"](parameters[0...10])
    req.callbacks["data"](parameters[10..-1])
    req.callbacks["end"]()
    expect(headers["Location"]).toEqual("/")
    expect(res.statusCode).toEqual(301)
    expect(createdPerson).toEqual(new Person("Darth Vader"))
    