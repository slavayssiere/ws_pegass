require './ws'
require './slack_bot/bot'

map('/v1') { run PegassApp }

pegassBot = PegassBot.new
pegassBot.start_bot
