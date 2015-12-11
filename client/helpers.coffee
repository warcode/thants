UnreadCount = 0

UpdateFavicon = (url)->
	console.log("updating favicon")
	console.log(url)
	link = document.createElement('link')
	link.type = 'image/x-icon'
	link.rel = 'shortcut icon'
	link.href = url
	$('*[type="image/x-icon"]').remove()
	document.getElementsByTagName('head')[0].appendChild(link)
	#$('*[type="image/x-icon"]:not(:last-child)').remove()

Template.body.helpers
	uploadingAvatar: ->
		uploading = Session.get 'uploadingavatar'
		if uploading is "true"
			return true
		return false

	partyTime: ->
		partyTime = Session.get 'partytime'
		if partyTime is "true"
			return true
		return false

	managingUsers: ->
		managing = Session.get 'manageusers'
		if managing is "true"
			return true
		return false

Template.main_phone.helpers 
	mainGestures:
		'panup .message-container, pandown .message-container, swipeup .message-container, swipedown .message-container': (event, templateInstance) ->
			if event.direction is 8
				document.getElementById('message-container').scrollTop = document.getElementById('message-container').scrollTop + (event.distance * 0.1)
			if event.direction is 16
				document.getElementById('message-container').scrollTop = document.getElementById('message-container').scrollTop - (event.distance * 0.1)
			return

		'swipeleft .message-container, swiperight .message-container': (event, templateInstance) ->
			console.log(event.direction)
			if event.direction is 2
				if $('.menuleft').css('display') is 'none'
					$('.menuright').show()
				else
					$('.menuleft').hide()
			if event.direction is 4
				if $('.menuright').css('display') is 'none'
					$('.menuleft').show()
				else
					$('.menuright').hide()

			console.log(event.direction)
			console.log("swiping leftright")
			return

	configureHammer: ->
		(hammer, templateInstance) ->
			hammer.set({ preventDefault: true })
			twoFingerSwipe = new (Hammer.Swipe)(
				event: '2fingerswipe'
				pointers: 2
				velocity: 0.5)
			hammer.add twoFingerSwipe
			hammer



Template.messages.helpers
	channelMessages: ->
		channel = Session.get 'channel'
		Messages.find({channel: channel}, {sort: [["time", "desc"]]})

Template.message.helpers
	formatTimestamp: ->
		return moment(this.time).format("X")

	formatTime: ->
		return if moment().diff(this.time, 'hours') > 24 then moment(this.time).format("HH:mm:ss") + ", " +moment(this.time).fromNow() else moment(this.time).format("HH:mm:ss")
		#format("YYYY-MM-DD HH:mm:ss")

	formatTimeTitle: ->
		return moment(this.time).format("YYYY-MM-DD HH:mm:ss")

	userClass: ->
		if this.user is 'ANTS'
			return "user ants"
		return "user"

	avatar: ->
		if this.user is 'ANTS'
			return '/thants_active.png'
		return "/api/avatars/#{this.user}.png"

	messageId: ->
		return this._id

	formatContent: ->
		content = this.text

		if this.encrypted?
			if this.encrypted is true
				decrypted = ""
				currentSecret = localStorage.getItem("thants.#{this.channel}.encryption")
				if currentSecret?
					decrypted = CryptoJS.AES.decrypt(this.text, currentSecret).toString(CryptoJS.enc.Utf8)

				if decrypted is ""
					content = "***"
				else
					content = decrypted
		

		content = content.replace /\s[@][a-zA-Z0-9]{1,}\s/g , (match) ->
			match.replace '@', ''

		content = content.replace(/(?:\r\n|\r|\n)/g, '<br/>');

		if content[0] is ">"
			content = "<span class=\"quote\">#{content}</span>"
		else
			content = "<span class=\"\">#{content}</span>"

		if this.urls?
			urlList = this.urls

			if this.encrypted?
				if this.encrypted is true
					currentSecret = localStorage.getItem("thants.#{this.channel}.encryption")
					if currentSecret?
						for u in urlList
							u.url = CryptoJS.AES.decrypt(u.url, currentSecret).toString(CryptoJS.enc.Utf8)

			#linkify
			for url in this.urls
				content = content.replace url.url, "<a href=\"#{url.url}\" target=\"_new\">#{url.url}</a>"

			#embed first url only
			firstUrl = this.urls[0].url
			picture = firstUrl.match(/^(https:\/\/\S*\.(?:jpe?g|png))$/i)
			gif = firstUrl.match(/^(https:\/\/\S*\.(?:gif))$/i)
			webm = firstUrl.match(/^(https:\/\/\S*\.(?:webm|gifv))$/i)
			youtube = firstUrl.match(/^https:\/\/\S*(youtube\.com|youtu\.be)\/watch\?\S*v=(\w*)\S*$/i)
			imgur = firstUrl.match(/^https:\/\/\S*[\.]?(imgur\.com)\/(\w*)$/i)
			if picture?
				content += "<div><img class=\"embed-picture\" style='' src='" + picture[0] + "'></img></div>"
			if gif?
				content += "<div class=\"embed-gif\"><div class=\"embed-gif-text\">[Hover to play]</div><img class=\"\" src='" + gif[0] + "'></img></div>"
			if webm?
				webm[0] = webm[0].replace('.gifv', '.webm')
				content += "<video class=\"embed-webm\" style='' src='" + webm[0] + "' loop='' controls='' muted=''></video>"
			if youtube?
				content += "<iframe src='https://www.youtube.com/embed/"+youtube[2]+"?wmode=transparent&amp;jqoemcache=xd8Cb' width='425' height='349' allowfullscreen='true' allowscriptaccess='always' scrolling='no' frameborder='0' style='max-width:60vw; max-height:50vh; width: 500px; height: 410.588235294118px; padding-top: 5px;''></iframe>"
			if imgur?
				content += "<img class=\"embed-imgur\" style='' src='https://i.imgur.com/" + imgur[2] + ".png'></img>"

		return content

Template.header.helpers
	inChannel: ->
		channel = Session.get 'channel'

		if channel is "LOBBY"
			return false

		return true

	channelName: ->
		Session.get 'channel'

	channelTopic: ->
		channel = Session.get 'channel'
		instance = Channels.findOne({_id : channel})
		if instance?
			instance.topic

	channelCurrent: ->
		channel = Session.get 'channel'
		instance = Channels.findOne({_id : channel})
		if !instance?
			return 0
		return Meteor.users.find({'status.online': true, username: { $in: instance.who } }).count()

	channelCount: ->
		channel = Session.get 'channel'
		instance = Channels.findOne({_id : channel})
		if instance?
			instance.members.length

	channelWho: ->
		return ""
		channel = Session.get 'channel'
		if channel is "library"
			return ""
		instance = Channels.findOne({_id : channel})
		if instance? and instance.who?
			online = Meteor.users.find({'status.online': true, username: { $in: instance.who } })
			#online = Meteor.users.find({'status.online': true, 'status.idle': false, username: { $in: instance.who } })
			return (x.username for x in online.fetch()).join(', ')

Template.loginscreen.helpers
	registering: ->
		registering = Session.get 'registering'
		if registering is "true"
			return true
		return false

Template.menuleft.helpers
	channelList: ->
		Meteor.user().profile.channels.sort()

	activeChannel: ->
		channel = Session.get 'channel'
		if this.toString() is channel.toString()
			return "channel active"
		return "channel"

	unreadChannel: ->
		current = this.toString()
		#if current is Session.get 'channel'
		#	return ""
		channel = Channels.findOne({_id : current})
		read = Unread.findOne({ channel : current})
		chan = Session.get('channel')
		if !read?
			if current is chan
				UpdateFavicon("/thants_newmessages.png?v=2")
				UnreadCount++
				titleString = chan + ' (' + UnreadCount + ')'
				Session.set 'title', titleString
				return ""
			return "unread"
		if read.lastread < channel.lastMessageTimestamp
			if current is chan
				UpdateFavicon("/thants_newmessages.png?v=2")
				UnreadCount++
				titleString = chan + ' (' + UnreadCount + ')'
				Session.set 'title', titleString
				return ""
			return "unread"

		if current is chan
			UpdateFavicon("/thants.png?v=2")
			UnreadCount = 0
			Session.set 'title', Session.get 'channel'
		return ""



Template.menuright.helpers
	userList: ->
		channel = Session.get 'channel'
		if channel is "library"
			return []
		instance = Channels.findOne({_id : channel})
		if instance? and instance.who?
			#online = Meteor.users.find({'status.online': true, 'status.idle': false, username: { $in: instance.who } })
			#check in the users channel list if they are in the channel!
			return Meteor.users.find({'status.online': true, 'profile.channels': channel })

	userIsOperator: ->
		channel = Session.get 'channel'
		instance = Channels.findOne({_id : channel, operators: this._id })
		if instance?
			return "op"
		return ""

	userIsIdle: ->
		if not Meteor.user().admin
			return ""
		if this.status.idle
			return "idle"
		else
			return "notidle"


Template.usermanager.helpers
	userList: ->
		return Meteor.users.find({})

Template.inputarea.helpers
	settings: ->
		channel = Session.get 'channel'
		{
			position: 'top'
			limit: 5
			rules: [{
				token: '@'
				collection: Meteor.users
				filter: {'status.online': true, 'profile.channels': channel }
				field: 'username'
				template: Template.autoPill
			}
			{
				token: '¤'
				collection: Meteor.users
				filter: {'status.online': true, 'profile.channels': channel }
				field: 'username'
				template: Template.autoPill
			}]
		}
	textAreaInit: ->
		return ""