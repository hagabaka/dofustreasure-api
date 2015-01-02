memjs = require 'memjs'

client = memjs.Client.create()
unless client.stats()
  data = null
  client =
    get: (_, callback) ->
      callback data
      data
    set: (_, value, callback) ->
      data = vale
      callback data
      data
  exports.get = client.get
  exports.set = client.set
else

exports.get = (callback) ->
  client.get 'data', (string) ->
    callback JSON.parse(string)

exports.set = (data, callback) ->
  client.set 'data', JSON.stringify(data)

