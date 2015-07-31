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

		message = { _id: Random.id(), channel: channel, text: msg}
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



	send = (message) ->
		console.log(message)
		Meteor.call 'sendMessage', message

	newInput: newInput
	send: send
)()