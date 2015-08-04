UpdateTitleMessage = ->
	console.log("not set at all")
	return

Template.messages.onCreated ->
  instance = this
  instance.autorun ->
  	instance.subscribe('messages', Session.get('channel'))
  	instance.subscribe('avatarsbychannel', Session.get('channel'))
  	#instance.subscribe('avatars')

Template.header.onCreated ->
	instance = this
	instance.autorun ->
		instance.subscribe('channels')
		instance.subscribe('userstatus', Session.get('channel'))

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


Template.avatarupload.events
	'dragover #dropzone': (event) ->
		event.stopPropagation()
		event.preventDefault()
		event.originalEvent.dataTransfer.dropEffect = 'copy'

	'drop #dropzone': (event) ->
		event.stopPropagation()
		event.preventDefault()
		file = event.originalEvent.dataTransfer.files[0]
		if file.type is "image/png"  and (file.size < 500000)
			console.log(file.name)
			reader = new FileReader()
			reader.onloadend = ->
  				Meteor.call 'commandSetAvatar', reader.result
  				return
			reader.readAsDataURL(file)
			Session.set 'uploadingavatar', ""


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
	text = content.html().toLowerCase()
	if (text.indexOf(username.toLowerCase()) > 0)
		$(element).toggleClass('highlight')

	#gif play control
	freezeframe.run()
	UpdateTitleMessage()


UnreadCount = 0

Template.body.onRendered ->
	$(window).bind 'blur', ->
		console.log("binding UpdateTitleMessage")
		UpdateTitleMessage = ->
			console.log("updating title message")
			link = document.createElement('link')
			link.type = 'image/x-icon'
			link.rel = 'shortcut icon'
			link.href = '/green.ico?v=2'
			document.getElementsByTagName('head')[0].appendChild(link)
			UnreadCount++
			chan = Session.get('channel')
			titleString = chan + ' (' + UnreadCount + ')'
			Session.set 'title', titleString
			console.log(Session.get 'title')
			return
		return

	$(window).bind 'focus', ->
		console.log("unbinding UpdateTitleMessage")
		link = document.createElement('link')
		link.type = 'image/x-icon'
		link.rel = 'shortcut icon'
		link.href = '/favicon.ico?v=2'
		document.getElementsByTagName('head')[0].appendChild(link)
		UnreadCount = 0
		Session.set 'title', Session.get 'channel'
		UpdateTitleMessage = ->
			UnreadCount = 0
			console.log("no title message update")
			return

		return