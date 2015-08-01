@InputHandler = (->
	self = {}
	wrapper = {}
	input = {}
	editing = {}

	newInput = (input, channel, msg) ->
		console.log("new input: " + msg)
		if msg[0] is '/'
			slashCommand(msg)
			input.val('')
			return

		message = { _id: Random.id(), channel: channel, text: msg }

		urls = msg.match /([A-Za-z]{3,9}):\/\/([-;:&=\+\$,\w]+@{1})?([-A-Za-z0-9\.]+)+:?(\d+)?((\/[-\+=!:~%\/\.@\,\w]+)?\??([-\+=&!:;%@\/\.\,\w]+)?#?([\w\/]+)?)?/g

		if urls?
			message.urls = urls.map (url) -> url: url

		send(message)
		input.val('')

	slashCommand = (msg) ->
		match = msg.match(/^\/([^\s]+)(?:\s+(.*))?$/m)
		if(match?)
			command = match[1].toLowerCase()
			param = match[2]
			
			if command is "join" or command is "j"
				parts = param.split(' ')
				channel = parts[0]
				password = parts[1]

				channel = channel.replace /[^a-zA-Z0-9]/g, ''

				Meteor.call 'commandJoin', channel, password, (err, joined) ->
					console.log(joined)
					if not joined
						swal
							title: 'ERROR' 
							text: 'Could not join ' + channel

					if joined
						FlowRouter.go('/chan/' + channel);

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



	send = (message) ->
		Meteor.call 'sendMessage', message
		#console.log(message)

	newInput: newInput
	send: send
)()