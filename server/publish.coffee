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

Meteor.publish 'avatarsbychannel', (channel) ->
	console.log("publishing avatarsbychannel")
	instance = Channels.findOne({ _id : channel}, { fields: {members: 1} })

	if not instance?
		return

	members = instance.members
	members.push('ANTS')
	return Avatars.find({_id : { $in: members} })

Meteor.publish 'userstatus', (channel) ->
	instance = Channels.findOne({ _id : channel}, { fields: { members: 1 } })
	return Meteor.users.find({ "status.online": true, _id : {$in: instance.members } }, { fields: { username: 1, 'status.online': 1, 'status.idle': 1} })