# Description:
#   Yamada bot helps to enjoy slack life
#
# Dependencies:
#   $ npm install
#
# Configuration:
#   You need to set following environment variables
#     SLACK_TOKEN METADATA_API_KEY CHANNEL
#
# Commands:
#   yamabo help          -- Display this help
#   yamabo ping          -- Check whether a bot is alive
#   yamabo weather       -- Ask today's weather
#   yamabo pollen        -- Ask today's pollen
#   yamabo yahoo-news    -- Display current yahoo news highlight
#   yamabo kindle        -- Display daily kindle sale book
#   yamabo train         -- Display train status
#   yamabo say [SOMETHING]       -- Yamada-bot say SOMETHING in general
#   yamabo emotion [SOMETHING]   -- Analyze [SOMETHING] using emotion API
#   yamabo ping [IPADDR]         -- Execute ping [IPADDR] from bot server
#   yamabo traceroute [IPADDR]   -- Execute traceroute [IPADDR] from bot server
#   yamabo whois [IPADDR]        -- Execute whois [IPADDR]
#   yamabo vote [TITLE] [ITEM1],[ITEM2],[ITEM3] -- Create vote template
#   yamabo center [STATION1],[STATION2],[STATION3] -- Get center among stations
#   yamabo chat          -- Start chatting with a bot. To end chatting, input Bye or bye
#

Botkit  = require 'botkit'
cron    = require('cron').CronJob
helper  = require './helper.coffee'
os      = require 'os'
request = require 'request'
sqlite3 = require('sqlite3').verbose()

controller = Botkit.slackbot debug: false

bot = controller.spawn token:process.env.SLACK_TOKEN
  .startRTM()

# add good to yamabo mention
controller.hears ['yamabo', 'YAMABO', 'やまぼ', 'ヤマボ'], 'ambient', (bot, message) ->
  bot.api.reactions.add { timestamp: message.ts, channel: message.channel, name: '+1' }, (err, res) ->
    if err?
      bot.botkit.log 'Failed to add emoji reaction :(', err

controller.hears ['tengu', 'TENGU', '天狗', 'てんぐ', 'テング'], 'ambient', (bot, message) ->
  bot.api.reactions.add { timestamp: message.ts, channel: message.channel, name: 'yamada' }, (err, res) ->
    if err?
      bot.botkit.log 'Failed to add emoji reaction :(', err

# yamabo chat
controller.hears ['^chat'], 'direct_message,direct_mention,mention', (bot,message) ->
  bot.startConversation message, greeting

greeting = (response, convo) ->
  respond response, convo, 'こんにちは'

respond = (response, convo, message) ->
  convo.ask message, (response, convo) ->
    query = response['text'].trim()
    if /^Bye|bye|またね|ばいばい|バイバイ|じゃあね|じゃあまた$/.test(query)
      convo.say 'バイバイ'
      convo.next()
    else
      # get context from DB
      console.log response
      db = new sqlite3.Database './db.sqlite3'
      db.get "SELECT * FROM zatsudan WHERE userid LIKE ? AND  teamid LIKE ?", response.user, response.team, (err, row) ->
        if row?
          context = row.context
        key = process.env.DOCOMO_TOKEN
        url = 'https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=' + key
        request.post
          url: url
          json:
            utt: query
            context: context if context
          , (err, res, body) ->
            console.log body
            if ! context?
              insert = db.prepare "INSERT INTO zatsudan VALUES (?,?,?)"
              insert.run response.team, response.user, body.context
              insert.finalize
            db.close
            respond response, convo, body.utt
            convo.next()

# yamabo help
controller.hears ['^help'], 'direct_message,direct_mention,mention', (bot,message) ->
  bot.reply message, '''
```
yamabo help          -- Display this help
yamabo ping          -- Check whether a bot is alive
yamabo weather       -- Ask today's weather
yamabo pollen        -- Ask today's pollen
yamabo yahoo-news    -- Display current yahoo news highlight
yamabo kindle        -- Display daily kindle sale book
yamabo train         -- Display train status
yamabo say [SOMETHING]       -- Yamada-bot say SOMETHING in general
yamabo emotion [SOMETHING]   -- Analyze [SOMETHING] using emotion API
yamabo ping [IPADDR]         -- Execute ping [IPADDR] from bot server
yamabo traceroute [IPADDR]   -- Execute traceroute [IPADDR] from bot server
yamabo whois [IPADDR]        -- Execute whois [IPADDR]
yamabo vote [TITLE] [ITEM1],[ITEM2],[ITEM3] -- Create vote template
yamabo center [STATION1],[STATION2],[STATION3] -- Get center among stations
yamabo chat          -- Start chatting with a bot. To end chatting, input Bye or bye
```
                     '''

# yamabo ping/yamabo ping 8.8.8.8
controller.hears ['^ping(.*)'], 'direct_message,direct_mention,mention', (bot, message) ->
  matches = message.text.match /ping(.*)/i
  if matches[1].length < 1
    bot.reply message, 'PONG'
  else
    ip_addr = matches[1].trim()
    if helper.isIpaddr ip_addr
      exec = require('child_process').exec
      exec "ping #{ip_addr} -c 5", (error, stdout, stderr) ->
        if stdout?
          bot.reply message, "```#{stdout}```"
        else
          bot.reply message, 'Something wrong'
    else
      bot.reply message, 'Omae IPv4 address mo wakaranaino'

# yamabo traceroute 8.8.8.8
controller.hears ['^traceroute(.*)'], 'direct_message,direct_mention,mention', (bot, message) ->
  matches = message.text.match /traceroute(.*)/i
  if matches[1].length < 1
    bot.reply message, 'IPv4 address wo iretene'
  else
    ip_addr = matches[1].trim()
    if helper.isIpaddr ip_addr
      exec = require('child_process').exec
      exec "traceroute #{ip_addr}", (error, stdout, stderr) ->
        if stdout?
          bot.reply message, "```#{stdout}```"
        else
          bot.reply message, 'Something wrong'
    else
      bot.reply message, 'Omae IPv4 address mo wakaranaino'

# yamabo whois 8.8.8.8
controller.hears ['^whois(.*)'], 'direct_message,direct_mention,mention', (bot, message) ->
  matches = message.text.match /whois(.*)/i
  if matches[1].length < 1
    bot.reply message, 'IPv4 address wo iretene'
  else
    ip_addr = matches[1].trim()
    if helper.isIpaddr ip_addr
      exec = require('child_process').exec
      exec "whois #{ip_addr}", (error, stdout, stderr) ->
        if stdout?
          bot.reply message, "```#{stdout}```"
        else
          bot.reply message, 'Something wrong'
    else
      bot.reply message, 'Omae IPv4 address mo wakaranaino'

# yamabo weather
controller.hears ['^weather'], 'direct_message,direct_mention,mention', (bot, message) ->
  helper.getWeather (weathers) ->
    res  = "今日の天気は#{weathers[0]['telop']}ってとこだな。"
    res += "最高気温は#{weathers[0]['maxtemp']}度らしいよ。" if weathers[0]['maxtemp']?
    res += "\nちなみに明日は#{weathers[1]['telop']}よ。"
    res += "最高気温は#{weathers[1]['maxtemp']}度らしいよ。" if weathers[1]['maxtemp']?
    bot.reply message, res

# yamabo yahoo-news
controller.hears ['^yahoo-news'], 'direct_message,direct_mention,mention', (bot, message) ->
  helper.getYahooNews (items) ->
    bot.reply message, "Yahoo Newsな。詳細は自分で確認して。"
    for item in items
      bot.reply message, "・#{item}"

# yamabo pollen
controller.hears ['^pollen'], 'direct_message,direct_mention,mention', (bot, message) ->
  helper.getPollen (pollens) ->
    bot.reply message, "今日は「花粉は#{pollens[0]}」ってさ"

# yamabo kindle
controller.hears ['^kindle'], 'direct_message,direct_mention,mention', (bot, message) ->
  helper.getKindleBook (book) ->
    bot.reply message, "今日のKindle日替わりセール本は「#{book}」よ。買うしかないっしょ!!"

# yamabo say something
controller.hears ['^say (.*)'], 'direct_message,direct_mention,mention', (bot, message) ->
  matches = message.text.match /say (.*)/i
  bot.say { channel: process.env.CHANNEL, text: matches[1].trim()}

# yamabo say train
controller.hears ['^train'], 'direct_message,direct_mention,mention', (bot, message) ->
  helper.getDelayedTrain (trains) ->
    if trains.length > 0
      bot.reply message, '遅延してる電車な。'
      for train in trains
        bot.reply message, "・#{train}"
    else
      bot.reply message, '遅延は特になし。'

# yamabo emotion something
controller.hears ['^emotion (.*)'], 'direct_message,direct_mention,mention', (bot, message) ->
  matches = message.text.match /emotion (.*)/i
  text = matches[1].trim()
  apikey = process.env.METADATA_API_KEY
  options = {
    url: 'http://ap.mextractr.net/ma9/emotion_analyzer?out=json&text=' + text + '&apikey=' + apikey,
    json: true
  }
  request.get options, (error, response, json) ->
    if !error && response.statusCode == 200
      json.analyzed_text = decodeURI(json.analyzed_text)
      bot.reply message, "```\n" + JSON.stringify(json, null, "\t") + "\n```"

# yamabo vote title item1,item2,item3
controller.hears ['^vote (.*)'], 'direct_message,direct_mention,mention', (bot, message) ->
  matches = message.text.match /vote (.*)/i
  params = matches[1].trim().split(" ")
  title = params[0]
  items = params.slice(1).join(" ").split(",")
  bot.reply message, "#{title}の投票するよ"
  bot.reply message, "集計するときは-1を忘れずに(yamaboを除く)"
  bot.reply message, "-----------------------------------------"
  helper.postMessages message, items

# yamabo center eki1,eki2,eki3
controller.hears ['^center (.*)'], 'direct_message,direct_mention,mention', (bot, message) ->
  matches = message.text.match /center (.*)/i
  params  = matches[1].trim().split(" ")
  items   = params.slice(0).join(" ").split(",")
  helper.getCenter items, (row) ->
    bot.reply message, "中心は「#{row.station_name}」駅だな"

# morning cron
new cron '00 00 7 * * *', () ->
  ch = process.env.CHANNEL
  bot.say { channel: ch, text: 'おはよう。今日も飛ばしていこうぜ。' }
  helper.getYahooNews (items) ->
    bot.say { channel: ch, text: '[Yahoo News]' }

    for item in items
      bot.say { channel: ch, text: "・#{item}" }
    helper.getKindleBook (book) ->
      bot.say { channel: ch, text: "[Kindleセール本]\n#{book}"}
      helper.getWeather (weathers) ->
        helper.getPollen (pollens) -> 
          msg = "[天気]\n今日: #{weathers[0]['telop']}"
          msg += " - 最高気温 #{weathers[0]['maxtemp']}度" if weathers[0]['maxtemp']?
          msg += " - 花粉 #{pollens[0]}"
          msg += "\n明日: #{weathers[1]['telop']}"
          msg += " - 最高気温 #{weathers[1]['maxtemp']}度" if weathers[1]['maxtemp']?
          msg += " - 花粉 #{pollens[1]}"
          bot.say { channel: ch, text: msg}
          
          helper.getDelayedTrain (trains) ->
            bot.say { channel: ch, text: '[電車遅延情報]' }
            if trains.length > 0
              for train in trains
                bot.say { channel: ch, text: "・#{train}" }
            else
              bot.say { channel: ch, text: '遅延なし' }
, null, true, "Asia/Tokyo"

# evening cron 1
new cron '00 30 17 * * 1-5', () ->
  ch = process.env.CHANNEL
  helper.isHoliday () ->
    bot.say { channel: ch, text: '社畜の通過... おっと休日だったか' }
  , () ->
    bot.say { channel: ch, text: '社畜の通過点...今週はヤマダの定時チャレンジ。みんな応援しろよな' }
, null, true, "Asia/Tokyo"

# evening cron 2
new cron '00 00 18 * * 1-5', () ->
  ch = process.env.CHANNEL
  helper.isHoliday () ->
    null
  , () ->
    bot.say { channel: ch, text: 'さすがにヤマダは帰ったか。お前らも帰れよ。社畜かよ。' }
, null, true, "Asia/Tokyo"
