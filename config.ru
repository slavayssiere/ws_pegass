require './ws'
require './slack_bot/bot'

map('/v1') { run PegassApp }
