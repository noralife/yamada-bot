expect = require('chai').expect

Robot       = require('hubot/src/robot')
TextMessage = require('hubot/src/message').TextMessage

describe 'ping', ->
  robot = null
  user = null
  adapter = null

  beforeEach (done) ->
    robot = new Robot(null, 'mock-adapter', false, 'hubot')

    robot.adapter.on 'connected', ->
      require('../scripts/yamada')(robot)
      user = robot.brain.userForId '1',
        name: 'mocha'
        room: '#mocha'
      adapter = robot.adapter
      done()
    robot.run()

  afterEach -> robot.shutdown()

  it 'responds "ping"', (done) ->
    adapter.on 'send', (envelope, strings) ->
      try
        expect(envelope.user.name).to.equal('mocha')
        expect(strings[0]).to.equal('PONG')
        do done
      catch e
        done e

    adapter.receive(new TextMessage(user, 'hubot ping'))
