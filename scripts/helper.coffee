# Description:
#   Helper methods for Yamada bot
#
# Dependencies:
#   $ npm install
#
# Configuration:
#   You need to set following environment variables
#     SLACK_TOKEN METADATA_API_KEY CHANNEL

cheerio         = require 'cheerio'
cheerio-httpcli = require 'cheerio-httpcli'
request         = require 'request'

module.exports =

  isIpaddr: (text) ->
    if /^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/.test(text)
      true
    else
      false

  getWeather: (callback) ->
    options = {
      url: 'http://weather.livedoor.com/forecast/webservice/json/v1?city=130010',
      json: true
    }
    request.get options, (error, response, json) ->
      if !error && response.statusCode == 200
        weathers = []
        for forecast in json.forecasts
          weather = []
          weather['telop'] = forecast.telop
          weather['maxtemp'] = forecast.temperature.max.celsius if forecast.temperature.max?
          weather['mintemp'] = forecast.temperature.min.celsius if forecast.temperature.min?
          weathers.push weather
        callback(weathers)
      else
        console.log('error: '+ response.statusCode)
  
  getKindleBook: (callback) ->
    cheerio-httpcli.fetch 'http://www.amazon.co.jp/b?node=3338926051', {}, (err, $, res)->
      book =  $('h3').text()
      callback(book)
  
  getYahooNews: (callback) ->
    cheerio-httpcli.fetch 'http://www.yahoo.co.jp/', {}, (err, $, res)->
      items = []
      $('ul.emphasis > li > a').each ()->
        items.push($(this).text())
      callback(items)
  
  getDelayedTrain: (callback) ->
    cheerio-httpcli.fetch 'http://api.tetsudo.com/traffic/atom.xml?kanto', {}, (err, $, res)->
      trains = []
      $('entry > title').each ()->
        if /JR東日本|東京メトロ|都営地下鉄|東武鉄道|西武鉄道|京成電鉄|京王電鉄|小田急電鉄|東急電鉄|京急電鉄|横浜市営地下鉄|りんかい線|つくばエクスプレス|ゆりかもめ|東京モノレール|日暮里・舎人ライナー/.test($(this).text())
          trains.push($(this).text())
      callback(trains)
  
  isHoliday: (holidayCallback, elseCallback) ->
    cheerio-httpcli.fetch 'http://s-proj.com/utils/checkHoliday.php?kind=h&opt=gov', {}, (err, $, res)->
      date = res.body.toString 'utf-8'
      if date is 'holiday'
        holidayCallback()
      else
        elseCallback()
  
  addReaction: (name, ch, ts, callback) ->
    options = {
      url: 'https://slack.com/api/reactions.add'
      qs: {
        'token': process.env.SLACK_TOKEN
        'name': name
        'channel': ch
        'timestamp': ts
      }
    }
    request.post options, (err, res, body) ->
      callback(JSON.parse(body))
      if err? or res.statusCode isnt 200
        console.log "Failed to add emoji reaction #{JSON.stringify(err)}"

  postMessage: (msg, text, callback) ->
    options = {
      url: 'https://slack.com/api/chat.postMessage'
      qs: {
        'token': process.env.SLACK_TOKEN
        'channel': msg.channel
        'text': text
        'as_user': true
      }
    }
    request.post options, (err, res, body) ->
      callback(JSON.parse(body))
      if err? or res.statusCode isnt 200
        console.log "Failed to post comment #{JSON.stringify(err)}"

  addReactions: (names, ch, ts) ->
    name = names.shift()
    if name?
      self = this
      this.addReaction name, ch, ts, (body) ->
        self.addReactions names, ch, ts

  postMessages: (msg, texts) ->
    text = texts.shift()
    if text?
      self = this
      this.postMessage msg, text, (body) ->
        self.addReactions ['+1', 'scream'], body.channel, body.ts
        self.postMessages msg, texts

