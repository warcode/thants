Meteor.startup ->
	Meteor.defer ->
		return
###
		book = Channels.findOne { _id: 'library' }
		if not book?
			Channels.insert
				_id: 'library'
				members: ['5AaGXpaGxSPQQC8Zf']
				who: [ 'ANTS' ]
				operators: ['ANTS']
				voices: [ 'ANTS' ]
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
				text: "*SCATTER EVERYWHERE* (/help)"
				urls: [{url : ""}]
				time: now

		avatar = Avatars.findOne({_id: "ANTS"})
		if not avatar?
			Avatars.insert
				_id : "ANTS" 
				username : "ANTS"
				avatar : "data:image/png;base64,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"
###