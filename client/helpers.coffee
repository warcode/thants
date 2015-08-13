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
		#console.log(managing)
		#permitted = Meteor.user().admin
		#console.log(permitted)
		if managing is "true"
			return true
		return false


Template.header.helpers
  inChannel: -> 
  	channel = Session.get 'channel'

  	if channel is "LOBBY"
  		return false

  	return true

  channelName: ->
  	Session.get 'channel'


Template.messages.helpers
	channelMessages: ->
		channel = Session.get 'channel'
		Messages.find({channel: channel}, {sort: [["time", "desc"]]})

Template.message.helpers
	formatTimestamp: ->
		return moment(this.time).format("X")

	formatTime: ->
		return moment(this.time).format("HH:mm:ss");

	userClass: ->
		if this.user is 'ANTS'
			return "user ants"
		return "user"

	avatar: ->
		data = Avatars.findOne({ username: this.user })
		if data?
			return data.avatar
		return ""

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
		

		if content[0] is ">"
			content = "<span class=\"quote\">#{content}</span>"

		if this.urls?
			console.log("message has urls")
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
			picture = firstUrl.match(/^(https:\/\/\S*\.(?:jpe?g|gif|png))$/i)
			webm = firstUrl.match(/^(https:\/\/\S*\.(?:webm|gifv))$/i)
			youtube = firstUrl.match(/^https:\/\/\S*[youtube.com|youtu.be]\/watch\?\S*v=(\w*)\S*$/i)
			imgur = firstUrl.match(/^https:\/\/\S*[imgur.com]\/(\w*)$/i)
			if picture?
				content += "<img class=\"\" style='max-width:60vw; max-height:50vh; width: auto; height: auto; padding-top: 5px;' src='" + picture[0] + "'></img>"
			if webm?
				webm[0] = webm[0].replace('.gifv', '.webm')
				content += "<video style='max-width:60vw; max-height:50vh; width: auto; height: auto; padding-top: 5px;' src='" + webm[0] + "' loop='' controls='' muted=''></video>"
			if youtube?
				content += "<iframe src='https://www.youtube.com/embed/"+youtube[1]+"?wmode=transparent&amp;jqoemcache=xd8Cb' width='425' height='349' allowfullscreen='true' allowscriptaccess='always' scrolling='no' frameborder='0' style='max-width:60vw; max-height:50vh; width: 500px; height: 410.588235294118px; padding-top: 5px;''></iframe>"
			if imgur?
				content += "<img class=\"\" style='max-width:60vw; max-height:50vh; width: auto; height: auto; padding-top: 5px;' src='https://i.imgur.com/" + imgur[1] + ".png'></img>"

		return content

Template.header.helpers
	channelTopic: ->
		channel = Session.get 'channel'
		instance = Channels.findOne({_id : channel})
		if instance?
			instance.topic

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


Template.usermanager.helpers
	userList: ->
		return Meteor.users.find({})