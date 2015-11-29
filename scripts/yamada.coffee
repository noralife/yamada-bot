module.exports = (robot) ->


   robot.respond /help/i, (res) ->
     res.send '''
```
yamada-bot help          -- Display this help
yamada-bot ping          -- Check whether a bot is alive
yamada-bot how are you?  -- Ask condition of the bot
yamada-bot who are you?  -- Ask a bot name
yamada-bot ping [IPADDR]         -- Execute ping [IPADDR] from bot server
yamada-bot traceroute [IPADDR]   -- Execute traceroute [IPADDR] from bot server
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

   robot.respond /ping(.*)/, (msg) ->
     if msg.match[1].length < 1
       msg.send "PONG"
     else
       ip_addr = msg.match[1].trim()
       if /^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/.test(ip_addr)
         @exec = require('child_process').exec
         @exec "ping #{ip_addr} -c 5", (error, stdout, stderr) ->
           msg.send error if error?
           msg.send stdout if stdout?
           msg.send stderr if stderr?
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
           msg.send error if error?
           msg.send stdout if stdout?
           msg.send stderr if stderr?
       else
         msg.send "Omae IPv4 address mo wakaranaino"

   robot.hear /Good night/i, (res) ->
     res.emote "Have a good night"

