@InputHandler = (->
	self = {}
	wrapper = {}
	input = {}
	editing = {}

	newInput = (input, channel, msg) ->
		console.log("new input: " + msg)

		if msg is ""
			input.val('')
			return

		if msg[0] is '/'
			slashCommand(msg, channel)
			input.val('')
			return

		message = { _id: Random.id(), channel: channel, text: msg }

		urls = msg.match /([A-Za-z]{3,9}):\/\/([-;:&=\+\$,\w]+@{1})?([-A-Za-z0-9\.]+)+:?(\d+)?((\/[-\+=!:~%\/\.@\,\w]+)?\??([-\+=&!:;%@\/\.\,\w]+)?#?([\w\/]+)?)?/g

		if urls?
			message.urls = urls.map (url) -> url: url

		send(message)
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

				Meteor.call 'commandJoin', channelToJoin, password, (err, joined) ->
					console.log(joined)
					if not joined
						swal
							title: 'ERROR' 
							text: 'Could not join ' + channelToJoin

					if joined
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

			if command is "logoutall" or command is "logoffall"
				Meteor.logoutOtherClients()
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
				Session.set 'partytime', "true"

			if command is "partyoff"
				Session.set 'partytime', ""

			if command is "help" or command is "?"
				swal
					title: 'Commands' 
					text:'/join channel password\n/leave\n/logout and /logoutall\n/avatar'



	send = (message) ->
		console.log("sending message")
		Meteor.call 'sendMessage', message
		

	newInput: newInput
	send: send
)()