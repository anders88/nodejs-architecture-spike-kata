phantom = require('phantom')
server = require('../person-web')


describe 'Person database', ->

  it "shows menu", ->
    finished = false
    phantom.create (ph) ->
      ph.createPage (page) ->
        page.open "http://localhost:#{server.port}", (status) ->
          expect(status).toEqual("success")
          page.evaluate (-> document.title), (title) ->
            expect(title).toEqual("Person Database")
            finished = true
            ph.exit()
    waitsFor () -> finished
    runs ->
      server.server.close()
