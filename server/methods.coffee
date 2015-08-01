Meteor.methods
	sendMessage: (message) ->

		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")

		console.log '[methods] sendMessage -> '.green, 'userId:', Meteor.userId(), 'arguments:', arguments

		user = Meteor.users.findOne Meteor.userId(), fields: username: 1

		internalChannelId = message.channel.toLowerCase()
		userId = Meteor.userId()

		permissionCheck = Channels.findOne({ _id : internalChannelId, members : userId })

		if permissionCheck?
			console.log("allowed to send message")

			now = new Date()
			Messages.insert
				userId : Meteor.userId()
				user: user.username
				channel: message.channel
				text: message.text
				urls: message.urls
				time: now

	commandJoin: (channel, password) ->
		console.log("trying to join channel " + channel + " using password " + password)

		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")

		internalChannelId = channel.replace /[^a-zA-Z0-9]/g, ''
		internalChannelId = internalChannelId.toLowerCase()

		userId = Meteor.userId()
		user = Meteor.users.findOne Meteor.userId(), fields: username: 1
		username = user.username

		existing = Channels.findOne({_id: internalChannelId})

		alreadyInChannel = Channels.findOne({ _id : channel, members : this.userId })

		if alreadyInChannel?
			return true

		if existing?
			console.log("existing")
			#check if we are allowed in by checking the locked + password
			if not existing.isLocked
				console.log("not locked")
				if existing.passwordHash is ""
					console.log("no password exists")
					Meteor.users.update({_id: userId}, {$push: { 'profile.channels' : internalChannelId }})
					Channels.update({_id: internalChannelId}, { $push: { members: userId, who: username } })
					return true

				if password is existing.passwordHash
					Meteor.users.update({_id: userId}, {$push: { 'profile.channels' : internalChannelId }})
					Channels.update({_id: internalChannelId}, { $push: { members: userId, who: username } })
					return true
			return false

		if not existing? 
			console.log("channel does not exist, creating it: " + channel + " with password: " + password)

			Channels.update
				_id: internalChannelId
			,
				_id: internalChannelId
				members: [ userId ]
				who: [ username ]
				operators: [ userId ]
				voices: []
				banned: []
				topic: "Welcome to #" + internalChannelId
				passwordHash: password ? ""
				encryptedKey: ""
				isLocked: false
				isMuted: false
			,
				upsert: true

			now = new Date()
			Messages.insert
				userId : "ANTS"
				user: "ANTS"
				channel: internalChannelId
				text: "*SCATTERS EVERYWHERE*"
				urls: [{url : ""}]
				time: now
			Meteor.users.update({_id: userId}, {$push: { 'profile.channels' : internalChannelId }})
			return true



	commandLeave: (channel) ->
		console.log("trying to leave channel")

	commandKick: (channel, user) ->
		console.log("trying to kick")

	commandBan: (channel, user) ->
		console.log("trying to ban")
