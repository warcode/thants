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

	user