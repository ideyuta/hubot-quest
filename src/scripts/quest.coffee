# Description:
#   HUBOT QUEST
#
# Configuration:
#
# Commands:
#
# Author:
#   ideyuta

CRON_TIME = process.env.HUBOT_JVN_CRON_TIME or '0 * * * * *'
ROOM_NAME = "Hubot"
POKEMON_TOTAL_NUM = 719

QUEST_TABLE_KEY = 'quest'

cron = require 'cron'

module.exports = (robot) ->

  user = {}

  robot.brain.set QUEST_TABLE_KEY, user

  new cron.CronJob CRON_TIME, ->
    pid = Math.floor(Math.random() * POKEMON_TOTAL_NUM) + 1
    getMonster pid, (pokemon) ->
      robot.messageRoom ROOM_NAME, "#{pokemon.name} [HP:#{pokemon.hp}]"
  , null, true

  # pokeapiからモンスターをとってくる
  getMonster = (pid, callback) ->
    robot.http("http://pokeapi.co/api/v1/pokemon/#{pid}/").get() (err, res, body) ->
      if callback
        if res.statusCode is not 200
          callback {statusCode: res.statusCode}
        else
          if err
            callback err
          else
            callback JSON.parse body

  # アクセスしてきたユーザーがHQをはじめているかチェックする
  startedCheck = (uid) ->
    _user = robot.brain.get QUEST_TABLE_KEY
    _user[uid]?

  # HQを開始する
  robot.respond /start/i, (msg) ->
    if startedCheck(msg.message.user.id)
      msg.send "すでにゲームをはじめています。statusを確認してください"
    else
      msg.send "-- HUBOT QUEST --"
      msg.send "キャラクターを作成します。キャラクター名[ #{msg.message.user.name} ]"
      user[msg.message.user.id] = { name: msg.message.user.name }
      robot.brain.save()

  # ユーザーステータスの確認
  robot.respond /status/i, (msg) ->
    if startedCheck(msg.message.user.id)
      uid = msg.message.user.id
      user = robot.brain.get QUEST_TABLE_KEY
      msg.send user[uid].name
    else
      msg.send "ゲームを開始していません。"
