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

	avatar: ->
		return "#{Meteor.absoluteUrl()}avatar/#{this.user.toLowerCase()}.png"

Template.header.helpers
	channelTopic: ->
		channel = Session.get 'channel'
		instance = Channels.findOne({_id : channel})
		if instance?
			instance.topic

	channelCount: ->
		channel = Session.get 'channel'
		instance = Channels.findOne({_id : channel})
		if instance?
			instance.members.length

	channelWho: ->
		channel = Session.get 'channel'
		instance = Channels.findOne({_id : channel})
		if instance?
			instance.who.join()

Template.loginscreen.helpers
	registering: ->
		registering = Session.get 'registering'
		if registering is "true"
			return true
		return false

Template.menuleft.helpers
	channelList: ->
		Meteor.user().profile.channels

	activeChannel: ->
		channel = Session.get 'channel'
		console.log(this)
		if this.toString() is channel.toString()
			return "channel active"
		return "channel"