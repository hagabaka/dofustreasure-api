fs = require 'fs'
script = fs.readFileSync 'jquery.ba-replacetext.js', encoding: 'UTF-8'
cheerio = require('cheerio')
cheerio.fn ?= cheerio.prototype
$ = jQuery = cheerio
eval script
module.exports = cheerio
