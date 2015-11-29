module.exports = (robot) ->


   robot.respond /help/i, (res) ->
     res.send '''
```
yamada-bot help          -- Display this help
yamada-bot ping          -- Check whether a bot is alive
yamada-bot how are you?  -- Ask condition of the bot
yamada-bot who are you?  -- Ask a bot name
```
              '''
   robot.respond /ping/i, (res) ->
     res.send "PONG"

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

   robot.hear /Good night/i, (res) ->
     res.emote "Have a good night"

