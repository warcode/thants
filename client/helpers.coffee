Template.header.helpers
  inChannel: -> 
  	channel = Session.get 'channel'

  	if channel is "LOBBY"
  		return false

  	return true

  channelName: ->
  	Session.get 'channel'


Template.messages.helpers
	channelMessages: ->
		channel = Session.get 'channel'
		Messages.find({channel: channel}, {sort: [["time", "desc"]]})

Template.message.helpers
	formatTimestamp: ->
		return moment(this.time).format("X")

	formatTime: ->
		return moment(this.time).format("HH:mm:ss");

	userClass: ->
		if this.user is 'ANTS'
			return "user ants"
		return "user"

Template.header.helpers
	channelTopic: ->
		channel = Session.get 'channel'
		Channels.findOne({_id : channel})

	channelCount: ->
		channel = Session.get 'channel'
		Channels.findOne({_id : channel}).members.length