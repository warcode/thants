Meteor.publish 'channelList', ->
	return Channels.find({}, { fields: { _id: 1}})

Meteor.publish 'channels', ->
	return Channels.find({ members : this.userId })

Meteor.publish 'messages', (channel) ->
	if channel is "library"
		return Messages.find({ channel : channel }, { limit: 10 })

	permissionCheck = Channels.findOne({ _id : channel, members : this.userId })

	if permissionCheck?
		#console.log("allowed to enter")
		Messages.find({ channel : channel }, {sort: [["time", "desc"]], limit: 100 })
	else
		#console.log("not allowed to enter")
		Messages.find({ channel : "library" })

Meteor.publish 'users', ->
	currentUser = Meteor.users.findOne({_id: this.userId})
	if currentUser.admin is true
		return Meteor.users.find({ _id: this.userId }, {fields: {_id: 1, username: 1, luck: 1, profile: 1, admin: 1, 'status.online': 1, 'status.idle': 1, 'status.userAgent': 1}})
	return Meteor.users.find({ _id: this.userId }, {fields: {_id: 1, username: 1, luck: 1, profile: 1, 'status.online': 1}})
	

Meteor.publish 'userstatus', (channel) ->
	currentUser = Meteor.users.findOne({_id: this.userId})
	if currentUser.admin is true
		return Meteor.users.find({ "status.online": true}, { fields: { username: 1, admin: 1, 'status.online': 1, 'status.idle': 1, 'profile.channels': 1} })	
	#_id : {$in: Channels.findOne({ _id : channel}, { fields: { members: 1 } }).members } }
	return Meteor.users.find({ "status.online": true}, { fields: { username: 1, 'status.online': 1, 'profile.channels': 1} })

Meteor.publish 'unread', ->
	return Unread.find({user : this.userId })