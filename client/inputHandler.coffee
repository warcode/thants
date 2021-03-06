@InputHandler = (->
	self = {}
	wrapper = {}
	input = {}
	editing = {}


	sanityCheck = (msg) ->
		console.log("sanity check")
		sane = msg
		sane = sane.replace(/[\.]{2,}/g , ".")
		sane = sane.replace(/[xX]{1,}[dD]{1,}/g, "ü")
		return sane

	newInput = (input, channel, msg) ->
		#console.log("new input: " + msg)

		if msg is ""
			input.val('')
			return

		if msg[0] is '/'
			slashCommand(msg, channel)
			input.val('')
			return

		msg = DOMPurify.sanitize(msg, {ALLOWED_TAGS: []})
		msg = sanityCheck(msg)

		message = { _id: Random.id(), channel: channel, text: msg }

		urls = msg.match /([A-Za-z]{3,9}):(\/\/|\?)([-;:&=\+\$,\w]+@{1})?([-A-Za-z0-9\.]+)+:?(\d+)?((\/[-\+=!:~%\/\.@\,\w]+)?\??([-\+=&!:;%@\/\.\,\w]+)?#?([\w\/\?=]+)?)?/g

		if urls?
			message.urls = urls.map (url) -> url: url

		channelInstance = Channels.findOne({_id: channel})
		if channelInstance.encryptedKey is ""
			send(message)
		else
			console.log("channel is using encryption")
			currentSecret = localStorage.getItem("thants.#{channel}.encryption")
			if not currentSecret?
				input.val('')
				return
			message.encrypted = true
			message.text = CryptoJS.AES.encrypt(message.text, currentSecret).toString()
			console.log("encrpyted input message")

			if message.urls?
				for urls in message.urls
					urls.url = CryptoJS.AES.encrypt(urls.url, currentSecret).toString()
				console.log("encrypted input urls")
			send(message)

		input.val('')

	newEdit = (id, input, channel, msg) ->
		if msg is ""
			input.val('')
			return

		if msg[0] is '/'
			input.val('')
			return

		msg = DOMPurify.sanitize(msg, {ALLOWED_TAGS: []})
		msg = sanityCheck(msg)

		message = Messages.findOne({_id: id})
		message.text = msg

		urls = msg.match /([A-Za-z]{3,9}):(\/\/|\?)([-;:&=\+\$,\w]+@{1})?([-A-Za-z0-9\.]+)+:?(\d+)?((\/[-\+=!:~%\/\.@\,\w]+)?\??([-\+=&!:;%@\/\.\,\w]+)?#?([\w\/\?=]+)?)?/g

		if urls?
			message.urls = urls.map (url) -> url: url

		channelInstance = Channels.findOne({_id: channel})
		if channelInstance.encryptedKey is ""
			edit(message)
		else
			console.log("channel is using encryption")
			currentSecret = localStorage.getItem("thants.#{channel}.encryption")
			if not currentSecret?
				input.val('')
				return
			message.encrypted = true
			message.text = CryptoJS.AES.encrypt(message.text, currentSecret).toString()
			console.log("encrpyted input message")

			if message.urls?
				for urls in message.urls
					urls.url = CryptoJS.AES.encrypt(urls.url, currentSecret).toString()
				console.log("encrypted input urls")
			edit(message)

		input.val('')

	slashCommand = (msg, channel) ->
		match = msg.match(/^\/([^\s]+)(?:\s+(.*))?$/m)
		if(match?)
			command = match[1].toLowerCase()
			param = match[2]
			
			if command is "join" or command is "j"
				parts = param.split(' ')
				channelToJoin = parts[0]
				password = parts[1]

				channelToJoin = channelToJoin.replace /[^a-zA-Z0-9]/g, ''

				encryptedK = null
				channelInstance = Channels.findOne({_id: channelToJoin})
				console.log("channel instance: " + channelInstance)
				if not channelInstance? and password?
					if ([channelToJoin].some (word) -> ~password.indexOf word) or ([password].some (word) -> ~channelToJoin.indexOf word)
						swal
							title: 'ERROR'
							text: 'Bad password'
						return
					console.log("channel does not exist, generating key material")
					keyMaterial = Random.id()
					keyMaterial = keyMaterial + channel
					keyMaterial = CryptoJS.SHA256(keyMaterial).toString()
					localStorage.setItem("thants.#{channelToJoin}.encryption", keyMaterial)
					encryptedK = CryptoJS.AES.encrypt(keyMaterial, password).toString()

				Meteor.call 'commandJoin', channelToJoin, password, encryptedK, (err, joined) ->
					console.log(joined)
					if not joined
						swal
							title: 'ERROR' 
							text: 'Could not join ' + channelToJoin

					if joined
						if joined is true
							FlowRouter.go('/chan/' + channelToJoin)
						else
							#console.log("got encryption key from server" + joined)
							key = CryptoJS.AES.decrypt(joined, password).toString(CryptoJS.enc.Utf8)
							#console.log("setting encryption key to " + key)
							localStorage.setItem("thants.#{channelToJoin}.encryption", key)
							FlowRouter.go('/chan/' + channelToJoin)

			if command is "leave" or command is "quit"
				Meteor.call 'commandLeave', channel, (err, left) ->
					if left
						FlowRouter.go('/chan/library')
					if not left
						swal
							title: 'ERROR'
							text: 'Could not leave ' + channel


			if command is "op"
				user = param
				Meteor.call 'commandOp', channel, user, (err, opd) ->
					if opd
						swal
							title: 'Complete'
							text: 'User made operator'
					if not opd
						swal
						title: 'ERROR'
						text: 'Could not op ' + user

			if command is "deop"
				swal
					title: 'ERROR' 
					text: 'Not implemented'

			if command is "ban"
				user = param
				Meteor.call 'commandBan', channel, user, (err, banned) ->
					if not banned
						swal
							title: 'ERROR' 
							text: 'Could not ban user'

			if command is "unban"
				user = param
				Meteor.call 'commandUnban', channel, user, (err, unbanned) ->
					if not unbanned
						swal
							title: 'ERROR' 
							text: 'Could not unban user'

			if command is "test"
				swal
					title: 'ERROR' 
					text:'TESTING TESTING'

			if command is "logout" or command is "logoff"
				Meteor.logout()
				console.log("logging out")

			if command is "logoutother" or command is "logoffother"
				Meteor.logoutOtherClients()
				console.log("logging out all")

			if command is "logoutall" or command is "logoffall"
				Meteor.logoutOtherClients()
				Meteor.logout()
				console.log("logging out all")

			if command is "avatar"
				Session.set 'uploadingavatar', "true"

			if command is "topic"
				topic = param
				Meteor.call 'commandTopic', channel, topic, (err, set) ->
					if not set
						swal
							title: 'ERROR' 
							text: 'Could not change topic in ' + channel

			if command is "party"
				source = param
				Meteor.call 'commandParty', channel, source, (err, set) ->
					if not set
						swal
							title: 'ERROR' 
							text: 'NOT OLD ENOUGH TO PARTY' + user
				

			if command is "partyoff"
				Meteor.call 'commandParty', channel, "", (err, set) ->
					if not set
						return

			if command is "partymute"
				Session.set('partymute', param)

			if command is "help" or command is "?"
				swal
					title: 'Commands' 
					text:'/join channel password\n/leave\n/logout and /logoutall\n/avatar'

			if command is "useradmin" or command is "manageusers"
				Session.set('manageusers', "true")
				console.log(Session.get 'manageusers')

			if command is "useradminclose" or command is "manageusersclose"
				Session.set('manageusers', "")

			if command is "firefox" or command is "daveplz"
				localStorage.setItem('thants.workaround.isFirefox', 'yes')

			if command is "invite"
				Meteor.call 'commandInvite', channel, user, (err, set) ->
					if not set
						swal
							title: 'ERROR' 
							text: 'Could not invite user ' + user

			if command is "nuke"
				chanName = param
				Meteor.call 'commandNuke', channel, chanName, (err, nuked) ->
					if not nuked
						swal
							title: 'ERROR' 
							text: 'Could not nuke channel'

			if command is "setpassword"
				splitparams = param.split(' ')
				usertochange = splitparams[0]
				newpassword = splitparams[1]
				Meteor.call 'commandSetPassword', usertochange, newpassword, (err, changed) ->
					if not changed
						swal
							title: 'ERROR'
							text: 'Could not change password for user'

			if command is "takeadmin"
				pw = param
				Meteor.call 'commandTakeAdmin', pw, (err, taken) ->
					if not taken
						swal
							title: 'ERROR'
							text: 'Could not grant admin rights'

			if command is "takeop"
				Meteor.call 'commandTakeOp', channel, (err, taken) ->
					if not taken
						swal
							title: 'ERROR'
							text: 'Could not grant operator rights'

			if command is "decrypt"
				pw = param
				Meteor.call 'commandDecrypt', channel, pw, (err, done) ->
					if done
						key = CryptoJS.AES.decrypt(done, pw).toString(CryptoJS.enc.Utf8)
						localStorage.setItem("thants.#{channel}.encryption", key)
						location.reload()
						#FlowRouter.go('/chan/' + channel)
					if not done
						swal
							title: 'ERROR'
							text: 'Could not decrypt'





	send = (message) ->
		console.log("sending message")
		Meteor.call 'sendMessage', message
		Meteor.call 'readChannel', Session.get 'channel'

	edit = (message) ->
		Meteor.call 'editMessage', message
		Meteor.call 'readChannel', Session.get 'channel'

	newInput: newInput
	newEdit: newEdit
	send: send
	edit: edit
)()