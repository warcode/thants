slideout = {}
editing = false
editId = null;

SendNotification = (msg) ->
	console.log("what")
	if Notification.permission != 'granted'
		Notification.requestPermission()
	else
		notification = new Notification(msg,
    		icon: "/thants.png?v=2"
			body: msg)


Template.messages.onCreated ->
  instance = this
  instance.autorun ->
  	instance.subscribe('messages', Session.get('channel'))

#Template.header.onCreated ->
#	instance = this
#	instance.autorun ->
		
Template.menuleft.onCreated ->
	instance = this
	instance.autorun ->
		instance.subscribe('channels')
		instance.subscribe('unread')

Template.menuright.onCreated ->
	instance = this
	instance.autorun ->
		instance.subscribe('userstatus', Session.get('channel'))

Template.messages.events
	'click .message-container': (event) ->
		Meteor.call 'readChannel', Session.get 'channel'
		$('.inputarea textarea').focus()

Template.inputarea.events
	'click .inputarea .send': (event) ->
		input = $(event.currentTarget).siblings("textarea")
		channel = Session.get 'channel'
		messageText = input.val()
		
		InputHandler.newInput input, channel, messageText

	'keydown .inputarea textarea': (event) ->
		if event.which is 27 #esc
			event.preventDefault()
			event.stopPropagation()

			editing = false
			input = $(event.currentTarget)
			input.val('')

		if event.which is 13 and not event.shiftKey #enter
			event.preventDefault()
			event.stopPropagation()
			
			input = $(event.currentTarget)
			channel = Session.get 'channel'
			messageText = input.val()
			
			if editing is true
				InputHandler.newEdit editId, input, channel, messageText
				editing = false
				editId = null
			else	
				InputHandler.newInput input, channel, messageText

		if event.which is 38 and event.shiftKey #arrow up
			event.preventDefault()
			event.stopPropagation()

			editing = true

			input = $(event.currentTarget)
			channel = Session.get 'channel'
			userid = Meteor.userId()
			message = Messages.findOne({channel: channel, userId: userid}, {sort: [["time", "desc"]]})
			editId = message._id

			decrypted = ""
			content = message.text
			if message.encrypted?
				if message.encrypted is true
					decrypted = ""
					currentSecret = localStorage.getItem("thants." + channel + ".encryption")
					if currentSecret?
						decrypted = CryptoJS.AES.decrypt(message.text, currentSecret).toString(CryptoJS.enc.Utf8)

					if decrypted is ""
						content = "***"
						editing = false
						editId = null
					else
						content = decrypted

			input.val(content)



Template.menuleft.events
	'click .menuleft .channel': (event) ->
		clicked = $(event.currentTarget)
		channel = '/chan/' + clicked.attr('data-channel')
		console.log(channel)
		FlowRouter.go channel
		Meteor.call 'readChannel', Session.get 'channel'


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


Template.main_phone.onRendered ->
	if Meteor.Device.isTablet() or Meteor.Device.isPhone()
		console.log("is phone: yes")


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
	
	$(element).toggleClass('pre-render')

	firefox = $('.message-container.firefox-plz')
	if firefox.length is 1
		trueHeight = firefox[0].scrollHeight - firefox.height() - $(element).height() - 30
		if (firefox.scrollTop() >= trueHeight)
			firefox.scrollTop(9999999999)


UnreadCount = 0

Template.body.onRendered ->
	$(window).bind 'blur', ->
		return

	$(window).bind 'focus', ->
		Meteor.call 'readChannel', Session.get 'channel'
		return

##FIREFOX
Template.messages.onRendered ->
	firefox = localStorage.getItem('thants.workaround.isFirefox')
	if firefox is "yes"
		console.log("we are in firefox")
		$('.message-container').addClass('firefox-plz')
##END FIREFOX