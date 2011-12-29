personweb = require('../person-controller')
htmlparser = require('htmlparser')
util = require('util')
select = require('soupselect').select

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
    req.url = "/"
    personweb.process(req, res)
    links = select(dom, "ul#menu li a")
    link_titles = links.map((n) -> n.children[0].data)
    expect(link_titles).toEqual ["Create person", "Find people"]
    
  it "shows create form", ->
    dom = null
    res.writeHead = () ->
    res.end = (html) ->
      dom = parse_html(html)
    req.url = "/person/create.html"
    personweb.process(req, res)
    expect(select(dom, 'form[method="post"] input[name="full_name"]')[0].attribs.type).toEqual("text")
    expect(select(dom, 'form[method="post"] input[type="submit"]')[0].attribs.value).toEqual("Create person")
