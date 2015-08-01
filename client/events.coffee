Template.messages.onCreated ->
  instance = this
  instance.autorun ->
  	instance.subscribe('messages', Session.get('channel'))

Template.header.onCreated ->
	instance = this
	instance.autorun ->
		instance.subscribe('channels')

Template.inputarea.events
	'click .inputarea .send': (event) ->
		input = $(event.currentTarget).siblings("textarea")
		channel = Session.get 'channel'
		messageText = input.val()
		
		InputHandler.newInput input, channel, messageText

	'keydown .inputarea textarea': (event) ->
		if event.which is 13 and not event.shiftKey
			event.preventDefault()
			event.stopPropagation()
			
			input = $(event.currentTarget)
			channel = Session.get 'channel'
			messageText = input.val()
			
			InputHandler.newInput input, channel, messageText

Template.menuleft.events
	'click .menuleft .channel': (event) ->
		clicked = $(event.currentTarget)
		channel = '/chan/' + clicked.attr('data-channel')
		console.log(channel)
		FlowRouter.go channel


Template.login.events
	'click .login .registerswitch': (event) ->
		console.log("go to register")
		Session.set('registering', "true")

	'click .login .loginButton': (event) ->
		username = $(event.target).siblings('#loginUsername').val()
		password = $(event.target).siblings('#loginPassword').val()
		Meteor.loginWithPassword username, password

	'keydown .login #loginPassword': (event) ->
		if event.which is 13 and not event.shiftKey
			event.preventDefault()
			event.stopPropagation()
			username = $(event.target).siblings('#loginUsername').val()
			password = $(event.target).val()
			Meteor.loginWithPassword username, password



Template.register.events
	'click .register .loginswitch': (event) ->
		Session.set('registering', "false")

	'click .register .registerButton': (event) ->
		username = $(event.target).siblings('#registerUsername').val()
		password = $(event.target).siblings('#registerPassword').val()
		confirm = $(event.target).siblings('#registerPasswordConfirm').val()

		if password is confirm
			Accounts.createUser
  				username: username
  				password: password

	'keydown .register #registerPasswordConfirm': (event) ->
		if event.which is 13 and not event.shiftKey
			event.preventDefault()
			event.stopPropagation()
			username = $(event.target).siblings('#registerUsername').val()
			password = $(event.target).siblings('#registerPassword').val()
			confirm = $(event.target).val()

			if password is confirm
				Accounts.createUser
	  				username: username
	  				password: password

Template.message.onRendered ->
	element = this.find('.message')
	
	#message grouping
	user = $(element).attr('data-user')
	prevUser = $(element).next().attr('data-user')

	time = $(element).attr('data-time')
	prevTime = $(element).next().attr('data-time')

	timeCheck = (time - prevTime) > 300

	if user?
		if prevUser is user and not timeCheck
			$(element).toggleClass('grouped')

	#highlight
	username = Meteor.user().username
	content = $(element).find('.message-content')
	text = content.html()
	if (text.indexOf(username) > 0)
		$(element).toggleClass('highlight')

	#gif play control
	freezeframe.run()

