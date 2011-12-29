personweb = require('../person-controller')
htmlparser = require('htmlparser')
util = require('util')

describe 'Person controller', ->

  it "shows menu", ->
    page = personweb.display_menu()
    expect(page).toContain "<ul"
    expect(page).toContain '<a href="person/create.html">'
    expect(page).toContain '<a href="person/list.html">'

  it "serves valid html", ->
    error = true
    handler = new htmlparser.DefaultHandler (parse_error,dom)->
      error = parse_error
    parser = new htmlparser.Parser(handler)
    parser.parseComplete(personweb.display_menu())
    expect(error).not.toBeTruthy()
    
   it "has a create person link", ->
    handler = new htmlparser.DefaultHandler
    parser = new htmlparser.Parser(handler)
    parser.parseComplete(personweb.display_menu())
    menu = handler.dom[0].children[3].children[1]
    expect(menu.name).toEqual("ul")
    expect(menu.attribs.id).toEqual("menu")
    expect(menu.children[1].name).toEqual("li")
    expect(menu.children[1].children[0].name).toEqual("a")
    expect(menu.children[1].children[0].children[0].data).toEqual("Create person")
    expect(menu.children[3].name).toEqual("li")
    expect(menu.children[3].children[0].name).toEqual("a")
    expect(menu.children[3].children[0].attribs.href).toEqual("person/list.html")
    expect(menu.children[3].children[0].children[0].data).toEqual("Find people")
    # Wishlist:
    # expect($(dom, "ul#menu li[1] a").text()).toEqual("Find people")
    
    