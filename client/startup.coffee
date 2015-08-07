Meteor.startup ->
	Meteor.subscribe('channelList')
	Meteor.subscribe('users')
	Tracker.autorun ->
		if Meteor.userId()
			try
				UserStatus.startMonitor
					threshold: 300000
					interval: 10000
					idleOnBlur: false
				console.log("starting idle monitor")
			catch err
				console.log(err.message)
		else
			UserStatus.stopMonitor()
		return

	Deps.autorun ->
		document.title = "thants : " + Session.get('title')
		return
	return