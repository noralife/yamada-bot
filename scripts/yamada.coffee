# Description:
#   Yamada bot helps to enjoy slack life
#
# Dependencies:
#   $ npm install
#
# Configuration:
#   You need to set following environment variables
#     HUBOT_SLACK_TOKEN
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
#   yamabo vote [TITLE] [ITEM1],[ITEM2],[ITEM3] -- Create vote template
#
# Author:
#   noralife
#

cheerio = require('cheerio')
cheerio-httpcli = require('cheerio-httpcli')
cron = require('cron').CronJob
request = require('request')

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
yamabo emotion [SOMETHING]   -- Analyze [SOMETHING] using emotion API
yamabo ping [IPADDR]         -- Execute ping [IPADDR] from bot server
yamabo traceroute [IPADDR]   -- Execute traceroute [IPADDR] from bot server
yamabo whois [IPADDR]        -- Execute whois [IPADDR]
yamabo vote [TITLE] [ITEM1],[ITEM2],[ITEM3] -- Create vote template
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

  getDelayedTrain = (callback) ->
    cheerio-httpcli.fetch 'http://api.tetsudo.com/traffic/atom.xml?kanto', {}, (err, $, res)->
      trains = []
      $('entry > title').each ()->
        if /JR東日本|東京メトロ|都営地下鉄|東武鉄道|西武鉄道|京成電鉄|京王電鉄|小田急電鉄|東急電鉄|京急電鉄|横浜市営地下鉄|りんかい線|つくばエクスプレス|ゆりかもめ|東京モノレール|日暮里・舎人ライナー/.test($(this).text())
          trains.push($(this).text())
      callback(trains)

  isHoliday = (holidayCallback, elseCallback) ->
    cheerio-httpcli.fetch 'http://s-proj.com/utils/checkHoliday.php?kind=h&opt=gov', {}, (err, $, res)->
      date = res.body.toString('utf-8')
      if date is 'holiday'
        holidayCallback()
      else
        elseCallback()

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
    getDelayedTrain (trains) ->
      if trains.length > 0
        msg.send "遅延してる電車な。"
        for train in trains
          msg.send "・#{train}"
      else
        msg.send "遅延は特になし。"

  robot.respond /emotion (.*)/i, (msg) ->
    text = msg.match[1].trim()
    apikey = process.env.METADATA_API_KEY
    options = {
      url: 'http://ap.mextractr.net/ma9/emotion_analyzer?out=json&text=' + text + '&apikey=' + apikey,
      json: true
    }
    request.get options, (error, response, json) ->
      if !error && response.statusCode == 200
        json.analyzed_text = decodeURI(json.analyzed_text)
        msg.send("```\n" + JSON.stringify(json, null, "\t") + "\n```")

  addReaction = (name, ch, ts, callback) ->
    options = {
      url: 'https://slack.com/api/reactions.add'
      qs: {
        'token': process.env.HUBOT_SLACK_TOKEN
        'name': name
        'channel': ch
        'timestamp': ts
      }
    }
    request.post options, (err, res, body) ->
      callback(JSON.parse(body))
      if err? or res.statusCode isnt 200
        robot.logger.error("Failed to add emoji reaction #{JSON.stringify(err)}")

  postMessage = (msg, text, callback) ->
    options = {
      url: 'https://slack.com/api/chat.postMessage'
      qs: {
        'token': process.env.HUBOT_SLACK_TOKEN
        'channel': msg.message.rawMessage.channel
        'text': text
        'username': 'yamabo'
        'as_user': true
      }
    }
    request.post options, (err, res, body) ->
      callback(JSON.parse(body))
      if err? or res.statusCode isnt 200
        robot.logger.error("Failed to post comment #{JSON.stringify(err)}")

  postMessages = (msg, texts) ->
    text = texts.shift()
    if text?
      postMessage msg, text, (body) ->
        addReactions(["+1", "scream"], body.channel, body.ts)
        postMessages(msg, texts)

  addReactions = (names, ch, ts) ->
    name = names.shift()
    if name?
      addReaction name, ch, ts, (body) ->
        addReactions names, ch, ts

  robot.respond /vote (.*)/i, (msg) ->
    params = msg.match[1].trim().split(" ")
    title = params[0]
    items = params.slice(1).join(" ").split(",")
    msg.send "#{title}の投票するよ"
    msg.send "集計するときは-1を忘れずに(yamaboを除く)"
    msg.send "-----------------------------------------"
    postMessages msg, items

  # cron
  new cron '00 00 7 * * *', () ->
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
          getDelayedTrain (trains) ->
            robot.send {room: ch}, "[電車遅延情報]"
            if trains.length > 0
              for train in trains
                robot.send {room: ch}, "・#{train}"
            else
              robot.send {room: ch}, "遅延なし"
  , null, true, "Asia/Tokyo"

  new cron '00 30 17 * * 1-5', () ->
    isHoliday () ->
      robot.send {room: "#general"}, "社畜の通過... おっと休日だったか"
    , () ->
      robot.send {room: "#general"}, "社畜の通過点...カイタはあと30分な"
  , null, true, "Asia/Tokyo"
