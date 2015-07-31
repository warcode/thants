Meteor.methods
	sendMessage: (message) ->

		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")

		console.log '[methods] sendMessage -> '.green, 'userId:', Meteor.userId(), 'arguments:', arguments

		user = Meteor.users.findOne Meteor.userId(), fields: username: 1

		now = new Date()
		Messages.insert
			userId : Meteor.userId()
			user: user.username
			channel: message.channel
			text: message.text
			urls: [{url : ""}]
			time: now

	commandJoin: (channel, password) ->
		console.log("trying to join channel " + channel + " using password " + password)
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")

		internalChannelId = channel.toLowerCase()

		userId = Meteor.userId()
		user = Meteor.users.findOne Meteor.userId(), fields: username: 1

		existing = Channels.findOne({_id: internalChannelId})

		if existing?
			console.log("existing")
			#check if we are allowed in by checking the locked + password
			if not existing.isLocked
				if existing.passwordHash is ""
					Channels.update({_id: internalChannelId}, { $push: { members: userId } })
					return
					
				if password is existing.passwordHash
					Channels.update({_id: internalChannelId}, { $push: { members: userId } })
					return

		if not existing? 
			console.log("channel does not exist, creating it: " + channel + " with password: " + password)

			Channels.update
				_id: internalChannelId
			,
				_id: internalChannelId
				members: [ userId ]
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



	commandLeave: (channel) ->
		console.log("trying to leave channel")

	commandKick: (channel, user) ->
		console.log("trying to kick")

	commandBan: (channel, user) ->
		console.log("trying to ban")
