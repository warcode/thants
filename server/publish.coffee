Meteor.publish 'channelList', ->
	return Channels.find({})

Meteor.publish 'channels', ->
	return Channels.find({ members : this.userId })

Meteor.publish 'messages', (channel) ->
	console.log("publishing channel " + channel)
	if channel is "library"
		return Messages.find({ channel : channel }, { limit: 10 })

	permissionCheck = Channels.findOne({ _id : channel, members : this.userId })

	if permissionCheck?
		console.log("allowed to enter")
		Messages.find({ channel : channel }, {sort: [["time", "desc"]], limit: 100 })
	else
		console.log("not allowed to enter")
		Messages.find({ channel : "library" })

Meteor.publish 'users', ->
	return Meteor.users.find({ _id: this.userId })

Meteor.publish 'avatars', ->
	return Avatars.find({})
