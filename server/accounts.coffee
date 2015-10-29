#Accounts.config { forbidClientAccountCreation: true }

Accounts.onCreateUser (options, user) ->
	if not Meteor.users.findOne({})?
		user.admin = true

	d6 = ->
		Math.floor(Random.fraction() * 6) + 1

	user.luck = d6() + d6() + d6()

	user.profile = {}
		
	if options.profile
		user.profile = options.profile

	user.profile.channels = [ "library" ]
	Channels.update({_id: 'library'}, { $push: { members: user._id, who: user.username } })

	if Meteor.settings.pushover.use is "yes"
		HTTP.call("POST", "https://api.pushover.net/1/messages.json", { params: { token: Meteor.settings.pushover.token, user: Meteor.settings.pushover.deliverygroup, message: "User registered: " + user.username }  })

	user