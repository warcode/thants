Template.body.helpers
	uploadingAvatar: ->
		uploading = Session.get 'uploadingavatar'
		if uploading is "true"
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
		uid = Meteor.user()._id
		data = Avatars.findOne({ _id: uid })
		if data?
			return data.avatar
		return ""

	formatContent: ->
		content = this.text

		if this.urls?
			console.log("message has urls")
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
				content += "<img crossOrigin=\"Anonymous\" class=\"freezeframe\" style='max-width:750px; max-height:525px; width: auto; height: auto; padding-top: 5px;' src='" + picture[0] + "'></img>"
			if webm?
				content += "<video style='max-width:750px; max-height:525px; width: auto; height: auto; padding-top: 5px;' src='" + webm[0] + "' loop='' controls='' muted=''></video>"
			if youtube?
				content += "<iframe src='https://www.youtube.com/embed/"+youtube[1]+"?wmode=transparent&amp;jqoemcache=xd8Cb' width='425' height='349' allowfullscreen='true' allowscriptaccess='always' scrolling='no' frameborder='0' style='max-height: 525px; max-width: 750px; width: 500px; height: 410.588235294118px; padding-top: 5px;''></iframe>"
			if imgur?
				content += "<img class=\"freezeframe\" style='max-width:750px; max-height:525px; width: auto; height: auto; padding-top: 5px;' src='https://i.imgur.com/" + imgur[1] + ".png'></img>"

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
		channel = Session.get 'channel'
		instance = Channels.findOne({_id : channel})
		if instance?
			instance.who.join()

Template.loginscreen.helpers
	registering: ->
		registering = Session.get 'registering'
		if registering is "true"
			return true
		return false

Template.menuleft.helpers
	channelList: ->
		Meteor.user().profile.channels

	activeChannel: ->
		channel = Session.get 'channel'
		console.log(this)
		if this.toString() is channel.toString()
			return "channel active"
		return "channel"