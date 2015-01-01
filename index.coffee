express = require 'express'
clues = require './clues'
storage = require './storage'

app = express()
app.set 'port', process.env.PORT || 5000
app.use (request, response, next) ->
  response.setHeader 'Cache-Control', 'Public'
  response.setHeader 'Access-Control-Allow-Origin', '*'
  next()

data = clues()
unless data
  storage.get (storedData) ->
    data = data || storedData

setInterval ->
  newData = clues()
  if newData
    storage.set JSON.stringify(data)
    data = newData
, 1800000

app.get '/', (request, response) ->
  if data
    response.send data

  else
    response.status(502).json({error: 'Error connecting to ImpsVillage'})

app.listen app.get('port'), ->
  console.log "Node app is running at localhost:#{app.get('port')}"
