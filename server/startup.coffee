Meteor.startup ->
	Meteor.defer ->
		book = Channels.findOne { _id: 'library' }
		if not book?
			Channels.insert
				_id: 'library'
				members: ['5AaGXpaGxSPQQC8Zf']
				who: []
				operators: ['5AaGXpaGxSPQQC8Zf']
				voices: []
				banned: []
				topic: "Welcome to #library"
				passwordHash: ""
				encryptedKey: ""
				isLocked: false
				isMuted: false

		message = Messages.findOne { channel: 'library'}
		if not message?
			now = new Date()
			Messages.insert
				userId : "ANTS"
				user: "ANTS"
				channel: "library"
				text: "*SCATTERS EVERYWHERE*"
				urls: [{url : ""}]
				time: now