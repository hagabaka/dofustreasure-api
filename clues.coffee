_ = require 'underscore'
$ = require './replace-text'
{page} = require './ipb'

# Elements of data are in the form {clue:, image:, source: {post:, author: }}
data = []

# Elements in OutputData are in the form {clue:, images: [image:, sources: {[post:, author:]}]}
outputData = []

processPage = (url) ->
  console.log "Processing page #{url}"

  page(url).then (parsedPage) ->
    parsedPage.posts().forEach (post) ->
      postBlock = post.body
      postBlock.add(postBlock.find('*')).replaceText /.+/, (text) ->
        if text isnt 'Spoiler' and not /^\s*$/.test(text)
          "<span class='possible_clue'>#{text}</span>"
        else
          ''

      textBlocksAndImages = postBlock.find('span.possible_clue, img')
      textBlocksAndImages.each (index, element) ->
        if element.tagName is 'img'
          img = $(element)
          clue = null
          if index > 0
            previous = (textBlocksAndImages)[0 .. index - 1].toArray().reverse()
            clueElement = _(previous).find (predecessor) -> predecessor.tagName is 'span'
            if clueElement
              text = $(clueElement).text().trim()
              # Clues are at most 9 words long, must start with letters, and can only contain
              # letters, whitespace, dash apostrophe, double quotes, parentheses, comma, slash,
              # and colon. An entire clue wrapped by '~ ... ~' is also accepted.
              letter = 'a-zA-Z\u00C0-\u017F'
              phrase = ///[ #{letter} ] [ - #{letter} \s ' " ( ) , : / ]+///.source
              if ///
                  ^ ~ \s+ #{phrase} \s+ ~ $ |
                  ^     " #{phrase} "     $ |
                  ^       #{phrase}       $
                 ///.test(text) and text.split(/\s+/).length <= 9

                data.push(
                  clue: text
                  image: img.attr('src')
                  source:
                    post: post.url
                    author: post.author
                    lastUpdated: post.editingDate()
                )

    nextPage = parsedPage.nextPage()
    if nextPage
      processPage nextPage
    else
      finish 0

finish = (status) ->
  outputData = []

  # Fix some typos
  fixes =
    'alchemists sign': 'Alchemist sign'
    'Bomard : (not sure if anyone posted this yet)': 'Bombard'
    'Broom in Astrub': 'Broom'
    'Cenatur statue': 'Centaur statue'
    'Clam with pearl': 'Clam with a pearl'
    'Frozen Pingwin and Kani': 'Frozen Pingwin and Kanigloo'
  data.forEach (entry) ->
    if entry.clue of fixes
      entry.clue = fixes[entry.clue]

  # Normalize clues FIXME capitalize first word and proper nouns, instead of all lower case
  data.forEach (entry) ->
    entry.clue = entry.clue.toLowerCase()
    entry.clue = entry.clue.replace /^"(.+)"$/, '$1'
    entry.clue = entry.clue.replace /\s*\(.+\)$/, ''
    entry.clue = entry.clue.replace /\s*".+"$/, ''
    entry.clue = entry.clue.replace /\s*:\s*$/, ''

  # Eliminate duplicate images, by having each image use the latest updated known clue
  clueForImage = {}
  data.forEach (entry) ->
    {clue, image, source: {lastUpdated}} = entry
    if clue and
       (image not of clueForImage or lastUpdated > clueForImage[image].lastUpdated)
      clueForImage[image] = {lastUpdated, clue}

  data.forEach (entry) ->
    entry.clue = clueForImage[entry.image]?.clue or '~ unknown clue ~'

  groupedByClue = _(data).groupBy 'clue'
  for clue of groupedByClue
    images = []
    groupedByImage = _(groupedByClue[clue]).groupBy 'image'
    for image of groupedByImage
      sources = groupedByImage[image].map (element) ->
        element.source
      sources = _(sources).sortBy 'lastUpdated'
      images.push {image, sources}
    outputData.push {clue, images}

  outputData = _(outputData).sortBy (entry) ->
    entry.clue.toLowerCase()
  console.log "Extracted #{outputData.length} clues"
  outputData

module.exports = ->
  data = []
  processPage('http://impsvillage.com/forums/topic/141320-treasure-hunting-the-guide/').catch (exception) ->
    console.log exception
    null

