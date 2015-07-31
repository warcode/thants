FlowRouter.route '/chan/:id',
	name: 'chan'
	action: (params, query) ->
		chanExists = Channels.find({ _id : params.id })

		if chanExists?
			Session.set 'channel', params.id
			console.log("channel is " + params.id)
		else
			console.log("channel is library")
			Session.set 'channel', "library"


FlowRouter.notFound =
  subscriptions: ->
  	
  action: ->
    FlowRouter.go '/chan/library'
    return