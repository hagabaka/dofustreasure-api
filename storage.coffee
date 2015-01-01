memjs = require 'memjs'

client = memjs.Client.create()
unless client.stats()
  data = null
  giveData = (key, callback) -> callback data
  client =
    get: giveData
    set: giveData
  exports.get = client.get
  exports.set = client.set
else

exports.get = (callback) ->
  client.get 'data', callback

exports.set = (data, callback) ->
  client.set 'data', data, callback

