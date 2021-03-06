bcrypt = Package['npm-bcrypt'].NpmModuleBcrypt

Meteor.methods
	sendMessage: (message) ->

		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "invalid user")

		user = Meteor.users.findOne Meteor.userId(), fields: username: 1

		internalChannelId = message.channel.toLowerCase()

		if internalChannelId is "library"
			return

		userId = Meteor.userId()

		permissionCheck = Channels.findOne({ _id : internalChannelId, members : userId })

		if permissionCheck?
			#console.log("allowed to send message")

			isEncrypted = false
			if message.encrypted?
				if message.encrypted is true
					isEncrypted = true

			now = new Date()
			Messages.insert
				userId : Meteor.userId()
				user: user.username
				channel: message.channel
				text: message.text
				urls: message.urls
				time: now
				encrypted: isEncrypted

			Channels.update
				_id: internalChannelId
			,
				{ $set:
					{
						lastMessageTimestamp: now
					}
				}

	editMessage: (message) ->
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "invalid user")

		if not message.userId is Meteor.userId()
			throw new Meteor.Error('invalid-user', "invalid user")

		#user = Meteor.users.findOne Meteor.userId(), fields: username: 1

		internalChannelId = message.channel.toLowerCase()
		userId = Meteor.userId()

		permissionCheck = Channels.findOne({ _id : internalChannelId, members : userId })

		if permissionCheck?
			existing = Messages.findOne({_id: message._id})
			now = new Date()
			Messages.update({_id: message._id}, {$set: {text: message.text, urls: message.urls, edited: now}})


	commandJoin: (channel, password, encryptedK) ->
		#console.log("trying to join channel " + channel + " using password " + password)

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
			#console.log("existing")
			#check if we are allowed in by checking the locked + password
			if not existing.isLocked
				#console.log("not locked")
				if existing.passwordHash is ""
					#console.log("no password exists")
					now = new Date()
					Meteor.users.update({_id: userId}, {$push: { 'profile.channels' : internalChannelId }})
					Channels.update({_id: internalChannelId}, { $push: { members: userId, who: username } })
					return true

				if not password?
					return false

				if bcrypt.compareSync(password, existing.passwordHash)
					#console.log("correct password")
					now = new Date()
					Meteor.users.update({_id: userId}, {$push: { 'profile.channels' : internalChannelId }})
					Channels.update({_id: internalChannelId}, { $push: { members: userId, who: username } })
					channelInstance = Channels.findOne({_id: internalChannelId})
					key = channelInstance.encryptedKey
					return key
			return false

		if not existing? 
			#console.log("channel does not exist, creating it: " + channel + " with password: " + password)

			hash = ""
			encryptedKey = ""
			if password?
				salt = bcrypt.genSaltSync(10)
				hash = bcrypt.hashSync(password, salt)
				encryptedKey = encryptedK

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
				passwordHash: hash
				encryptedKey: encryptedKey
				isLocked: false
				isMuted: false
			,
				upsert: true

			now = new Date()
			Messages.insert
				userId : "ANTS"
				user: "ANTS"
				channel: internalChannelId
				text: "*SCATTER EVERYWHERE*"
				urls: [{url : ""}]
				time: now
			Meteor.users.update({_id: userId}, {$push: { 'profile.channels' : internalChannelId }})
			return true



	commandLeave: (channel) ->
		console.log("trying to leave channel")
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")
			return false

		userInChannel = Channels.findOne({ _id : channel, members : this.userId })
		if not userInChannel?
			return false

		user = Meteor.users.findOne Meteor.userId(), fields: username: 1
		username = user.username
		Meteor.users.update({_id: this.userId}, {$pull: { 'profile.channels' : channel }})
		Channels.update({_id: channel}, { $pull: { members: this.userId, who: username, operators: this.userId, voices: this.userId } })
		return true




	commandKick: (channel, user) ->
		console.log("trying to kick")


	commandBan: (channel, user) ->
		console.log("trying to ban")
		if not Meteor.userId()			
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")
			return false

		if user is "ANTS"
			return false

		permissionCheck = Channels.findOne({ _id : channel, members : this.userId, operators : this.userId })

		if permissionCheck?
			#console.log("allowed to ban")
			userToBan = Meteor.users.findOne({ username: user },{ fields: {_id: 1 } })
			userIdToBan = userToBan._id

			userIsInChannel = Channels.findOne({ _id : channel, members : userIdToBan })

			if userIsInChannel?
				Meteor.users.update({_id: userIdToBan}, {$pull: { 'profile.channels' : channel }})
				Channels.update({_id: channel}, { $push: { banned: userIdToBan } })
				Channels.update({_id: channel}, { $pull: { members: userIdToBan, who: user, operators: userIdToBan, voices: userIdToBan } })
				return true

		return false


	commandUnban: (channel, user) ->
		console.log("trying to unban")
		if not Meteor.userId()			
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")
			return false

		permissionCheck = Channels.findOne({ _id : channel, members : this.userId, operators : this.userId })

		if permissionCheck?
			#console.log("allowed to unban")
			userToUnBan = Meteor.users.findOne({ username: user },{ fields: {_id: 1 } })
			userIdToUnBan = userToUnBan._id
			Channels.update({_id: channel}, { $pull: { banned: userIdToUnBan } })
			return true

		return false


	commandOp: (channel, user) ->
		console.log("trying to op " + user + " in " + channel)
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")
			return false

		console.log(this.userId)

		permissionCheck = Channels.findOne({ _id : channel, members : this.userId, operators : this.userId })
		if permissionCheck?
			#console.log("allowed to op")
			userToOp = Meteor.users.findOne({ username: user },{ fields: {_id: 1 } })
			userIdToOp = userToOp._id

			console.log(userIdToOp)

			alreadyOp = Channels.findOne({ _id : channel, operators : userIdToOp })
			if not alreadyOp?
				Channels.update({_id: channel}, { $push: { operators: userIdToOp } })
				return true

		return false



	commandTopic: (channel, topic) ->
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")

		#internalChannelId = channel.replace /[^a-zA-Z0-9]/g, ''
		internalChannelId = channel.toLowerCase()
		allowedToChangeTopic = Channels.findOne({ _id : internalChannelId, members : this.userId, operators: this.userId })

		if allowedToChangeTopic?
			Channels.update({_id: internalChannelId}, {$set : { topic: topic}})
			now = new Date()
			Messages.insert
				userId : "ANTS"
				user: "ANTS"
				channel: internalChannelId
				text: "Topic was set to: " + topic
				urls: [{url : ""}]
				time: now


	commandSetAvatar: (avatar) ->
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "invalid user")

		userId = Meteor.userId()
		username = Meteor.user().username

		Avatars.update
				_id: userId
			,
				_id: userId
				username: username
				avatar: avatar
			,
				upsert: true

	commandNuke: (channel, confirm) ->
		console.log("trying to nuke")
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")
			return false

		if channel is confirm and Meteor.user().admin
			Messages.remove
				channel: channel
		else
			return false

	commandSetPassword: (targetUser, newPassword) ->
		console.log("trying to set password")
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")
			return false

		passwordUser = Meteor.users.findOne({ username: targetUser },{ fields: {_id: 1 } })
		passwordUserId = passwordUser._id

		if Meteor.user().admin or Meteor.userId() is passwordUserId
			Accounts.setPassword(passwordUserId, newPassword, {logout: true})
			return true
		else
			return false

	commandTakeAdmin: (password) ->
		console.log("trying to take admin")
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")
			return false

		if Meteor.settings.admin.password is password
			Meteor.user().admin = true
			return true
		else
			return false

	commandTakeOp: (channel) ->
		console.log("trying to take op")
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")
			return false

		if Meteor.user().admin
			userIdToOp = Meteor.userId()
			alreadyOp = Channels.findOne({ _id : channel, operators : userIdToOp })
			if not alreadyOp?
				Channels.update({_id: channel}, { $push: { operators: userIdToOp } })
				return true

		return false

	commandDecrypt: (channel, password) ->
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")
			return false

		userId = Meteor.userId()
		alreadyInChannel = Channels.findOne({ _id : channel, members : this.userId })

		if alreadyInChannel?
			if bcrypt.compareSync(password, alreadyInChannel.passwordHash)
				key = alreadyInChannel.encryptedKey
				return key
				
		return false

	commandParty: (channel, source) ->
		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")

		internalChannelId = channel.toLowerCase()
		allowedToParty = Channels.findOne({ _id : internalChannelId, members : this.userId, operators: this.userId })

		if allowedToParty?
			Channels.update({_id: internalChannelId}, { $set: { party: source} })
			return true
		return false


	readChannel: (channel) ->
		#console.log("read channel: " + channel)
		now = new Date()

		read = Unread.findOne({_id : this.userId})
		if !read?		
			Unread.update
				user : this.userId
				channel : channel
			,
				user : this.userId
				channel : channel
				lastread : now
			,
				upsert: true

		Unread.update
			user : this.userId
			channel : channel
		,
			$set :
				lastread : now
