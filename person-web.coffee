
http = require('http')
controller = require('./person-controller')

port = 0
port = Number(process.argv[2]) if process.argv[2] and not isNaN(Number(process.argv[2]))

server = http.createServer (req,res) ->
  res.writeHead(200, 'Content-Type':'text/html')
  res.end(controller.display_menu())

server.listen(port, -> 
  console.log("Started on ", server.address().port)
  exports.port = server.address().port
)

exports.server = server
