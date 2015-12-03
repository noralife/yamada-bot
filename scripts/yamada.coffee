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
#   yamada-bot help          -- Display this help
#   yamada-bot ping          -- Check whether a bot is alive
#   yamada-bot weather       -- Ask today's weather
#   yamada-bot yahoo-news    -- Display current yahoo news highlight
#   yamada-bot kindle        -- Display daily kindle sale book
#   yamada-bot how are you?  -- Ask condition of the bot
#   yamada-bot who are you?  -- Ask a bot name
#   yamada-bot say [SOMETHING]       -- Yamada-bot say SOMETHING in #general
#   yamada-bot ping [IPADDR]         -- Execute ping [IPADDR] from bot server
#   yamada-bot traceroute [IPADDR]   -- Execute traceroute [IPADDR] from bot server
#   yamada-bot whois [IPADDR]        -- Execute whois [IPADDR]
#
# Author:
#   noralife
#

cheerio = require('cheerio')
cheerio-httpcli = require('cheerio-httpcli')

module.exports = (robot) ->


   robot.respond /help/i, (res) ->
     res.send '''
```
yamada-bot help          -- Display this help
yamada-bot ping          -- Check whether a bot is alive
yamada-bot weather       -- Ask today's weather
yamada-bot yahoo-news    -- Display current yahoo news highlight
yamada-bot kindle        -- Display daily kindle sale book
yamada-bot how are you?  -- Ask condition of the bot
yamada-bot who are you?  -- Ask a bot name
yamada-bot ping [IPADDR]         -- Execute ping [IPADDR] from bot server
yamada-bot traceroute [IPADDR]   -- Execute traceroute [IPADDR] from bot server
yamada-bot whois [IPADDR]        -- Execute whois [IPADDR]
```
              '''
   robot.respond /how are you?/i, (res) ->
     rand = Math.floor(Math.random() * 10) + 1
     if rand > 7
       res.send "I'm fine"
     else if rand >3
       res.send "I'm tired"
     else
       res.send "pardon?"

   robot.respond /who are you?/i, (res) ->
     rand = Math.floor(Math.random() * 10) + 1
     if rand > 7
       res.send "You know me..."
     else
       res.send "YaMaDa"

   robot.respond /vmstat/, (msg) ->
     @exec = require('child_process').exec
     @exec "vmstat", (error, stdout, stderr) ->
       msg.send error if error?
       msg.send stdout if stdout?
       msg.send stderr if stderr?

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

   robot.hear /Good night/i, (res) ->
     res.emote "Have a good night"

   # example for calling API
   robot.respond /weather/i, (msg) ->
     request = msg.http('http://weather.livedoor.com/forecast/webservice/json/v1')
                          .query(city: 130010)
                          .get()
     request (err, res, body) ->
       json = JSON.parse body
       console.log(json)
       console.log(json['forecasts'][0]['temperature'])
       weather = json['forecasts'][0]['telop']
       max_temperature =  json['forecasts'][0]['temperature']['max']
       message = "今日の天気は#{weather}ってとこだな。"
       message += "最高気温は#{max_temperature['celsius']}度らしいよ。" if max_temperature?
       msg.send message

   # example for scraping
   robot.respond /yahoo-news/i, (msg) ->
     msg.send "今のYahoo Newsな。詳細は自分で確認して。"
     cheerio-httpcli.fetch 'http://www.yahoo.co.jp/', {}, (err, $, res)->
       $('ul.emphasis > li > a').each ()->
         msg.send "・#{$(this).text()}"

   robot.respond /kindle/i, (msg) ->
     cheerio-httpcli.fetch 'http://www.amazon.co.jp/b?node=3338926051', {}, (err, $, res)->
       book =  $('h3').text()
       msg.send "今日のKindle日替わりセール本は「#{book}」よ。買うしかないっしょ。"

   robot.respond /say (.*)/i, (msg) ->
     robot.send {room: "#general"}, msg.match[1].trim()
