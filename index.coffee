express = require 'express'
clues = require './clues'

app = express()
app.set 'port', process.env.PORT || 5000
app.use (request, response, next) ->
  response.setHeader 'Cache-Control', 'Public'
  response.setHeader 'Access-Control-Allow-Origin', '*'
  next()

data = clues()
setInterval ->
  data = clues()
, 1800000

app.get '/', (request, response) ->
  response.send data

app.listen app.get('port'), ->
  console.log "Node app is running at localhost:#{app.get('port')}"
