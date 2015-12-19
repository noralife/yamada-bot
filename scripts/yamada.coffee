# Description:
#   Yamada bot helps to enjoy slack life
#
# Dependencies:
#   $ npm install
#
# Configuration:
#   You need to set following environment variables
#     HUBOT_SLACK_TOKEN
#     HUBOT_TWITTER_CONSUMER_KEY
#     HUBOT_TWITTER_CONSUMER_SECRET
#     HUBOT_TWITTER_ACCESS_TOKEN_KEY
#     HUBOT_TWITTER_ACCESS_TOKEN_SECRET
#     HUBOT_TWITTER_MENTION_QUERY
#     HUBOT_TWITTER_MENTION_ROOM
#
# Commands:
#   yamabo help          -- Display this help
#   yamabo ping          -- Check whether a bot is alive
#   yamabo weather       -- Ask today's weather
#   yamabo yahoo-news    -- Display current yahoo news highlight
#   yamabo kindle        -- Display daily kindle sale book
#   yamabo train         -- Display train status
#   yamabo say [SOMETHING]       -- Yamada-bot say SOMETHING in #general
#   yamabo ping [IPADDR]         -- Execute ping [IPADDR] from bot
#   yamabo traceroute [IPADDR]   -- Execute traceroute [IPADDR] from bot
#   yamabo whois [IPADDR]        -- Execute whois [IPADDR]
#
# Author:
#   noralife
#

cheerio = require('cheerio')
cheerio-httpcli = require('cheerio-httpcli')
cron = require('cron').CronJob
request = require('request');

module.exports = (robot) ->


  robot.respond /help/i, (res) ->
    res.send '''
```
yamabo help          -- Display this help
yamabo ping          -- Check whether a bot is alive
yamabo weather       -- Ask today's weather
yamabo yahoo-news    -- Display current yahoo news highlight
yamabo kindle        -- Display daily kindle sale book
yamabo train         -- Display train status
yamabo say [SOMETHING]       -- Yamada-bot say SOMETHING in general
yamabo ping [IPADDR]         -- Execute ping [IPADDR] from bot server
yamabo traceroute [IPADDR]   -- Execute traceroute [IPADDR] from bot server
yamabo whois [IPADDR]        -- Execute whois [IPADDR]
```
              '''

  # example for shell execution
  robot.respond /ping(.*)/, (msg) ->
    if msg.match[1].length < 1
      msg.send "PONG"
    else
      ip_addr = msg.match[1].trim()
      if /^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/.test(ip_addr)
        @exec = require('child_process').exec
        @exec "ping #{ip_addr} -c 5", (error, stdout, stderr) ->
          if stdout?
            msg.send "```#{stdout}```"
          else
            msg.send "Something wrong"
      else
        msg.send "Omae IPv4 address mo wakaranaino"

  robot.respond /traceroute(.*)/, (msg) ->
    if msg.match[1].length < 1
      msg.send "IPv4 address wo iretene"
    else
      ip_addr = msg.match[1].trim()
      if /^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/.test(ip_addr)
        @exec = require('child_process').exec
        @exec "traceroute #{ip_addr}", (error, stdout, stderr) ->
          if stdout?
            msg.send "```#{stdout}```"
          else
            msg.send "Something wrong"
      else
        msg.send "Omae IPv4 address mo wakaranaino"

  robot.respond /whois(.*)/, (msg) ->
    if msg.match[1].length < 1
      msg.send "IPv4 address wo iretene"
    else
      ip_addr = msg.match[1].trim()
      if /^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/.test(ip_addr)
        @exec = require('child_process').exec
        @exec "whois #{ip_addr}", (error, stdout, stderr) ->
          if stdout?
            msg.send "```#{stdout}```"
          else
            msg.send "Something wrong"

  getWeather = (callback) ->
    options = {
      url: 'http://weather.livedoor.com/forecast/webservice/json/v1?city=130010',
      json: true
    }
    request.get options, (error, response, json) ->
      if !error && response.statusCode == 200
        weathers = []
        for forecast in json.forecasts
          weather = []
          weather["telop"] = forecast.telop
          weather["maxtemp"] = forecast.temperature.max.celsius if forecast.temperature.max?
          weather["mintemp"] = forecast.temperature.min.celsius if forecast.temperature.min?
          weathers.push weather
        callback(weathers)
      else
        console.log('error: '+ response.statusCode)

  getKindleBook = (callback) ->
    cheerio-httpcli.fetch 'http://www.amazon.co.jp/b?node=3338926051', {}, (err, $, res)->
      book =  $('h3').text()
      callback(book)

  getYahooNews = (callback) ->
    cheerio-httpcli.fetch 'http://www.yahoo.co.jp/', {}, (err, $, res)->
      items = []
      $('ul.emphasis > li > a').each ()->
        items.push($(this).text())
      callback(items)

  # example for calling API
  robot.respond /weather/i, (msg) ->
    getWeather (weathers) ->
      console.log(weathers)
      message = "今日の天気は#{weathers[0]['telop']}ってとこだな。"
      message += "最高気温は#{weathers[0]['maxtemp']}度らしいよ。" if weathers[0]['maxtemp']?
      message += "\nちなみに明日は#{weathers[1]['telop']}よ。"
      msg.send message

  # example for scraping
  robot.respond /yahoo-news/i, (msg) ->
    getYahooNews (items) ->
      msg.send "Yahoo Newsな。詳細は自分で確認して。"
      for item in items
        msg.send "・#{item}"

  robot.respond /kindle/i, (msg) ->
    getKindleBook (book) ->
      msg.send "今日のKindle日替わりセール本は「#{book}」よ。買うしかないっしょ!!"

  robot.respond /say (.*)/i, (msg) ->
    robot.send {room: "#general"}, msg.match[1].trim()

  robot.respond /train/i, (msg) ->
    cheerio-httpcli.fetch 'http://api.tetsudo.com/traffic/atom.xml?kanto', {}, (err, $, res)->
      trains = []
      $('entry > title').each ()->
        trains.push($(this).text())
      if trains.length > 0
        msg.send "遅延してる電車な。"
        for train in trains
          msg.send "・#{train}"
      else
        msg.send "遅延は特になし。"

  # cron
  new cron '00 00 7 * * *', () =>
    ch = "#general"
    robot.send {room: ch}, "おはよう。今日も飛ばしていこうぜ。"
    getYahooNews (items) ->
      robot.send {room: ch}, "[Yahoo News]" 
      for item in items
        robot.send {room: ch}, "・#{item}"
      getKindleBook (book) ->
        robot.send {room: ch}, "[Kindleセール本]\n#{book}"
        getWeather (weathers) ->
          message = "[天気]\n今日: #{weathers[0]['telop']}"
          message += " - 最高気温は#{weathers[0]['maxtemp']}度" if weathers[0]['maxtemp']?
          message += "\n明日: #{weathers[1]['telop']}"
          message += " - 最高気温は#{weathers[1]['maxtemp']}度" if weathers[1]['maxtemp']?
          robot.send {room: ch}, message
  , null, true, "Asia/Tokyo"

  new cron '00 30 17 * * *', () =>
    robot.send {room: "#general"}, "社畜の通過点"
  , null, true, "Asia/Tokyo"
