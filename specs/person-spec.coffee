Person = require('../person').Person

describe "Person", ->

  it "creates person with full name", ->
    expect(new Person("Darth Vader").name).toEqual("Darth Vader")

