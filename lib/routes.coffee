FlowRouter.route '/chan/:id',
	name: 'chan'
	action: (params, query) ->
		Session.set 'channel', params.id
		Session.set 'title', params.id

FlowRouter.notFound =
  subscriptions: ->

  action: ->
    FlowRouter.go '/chan/library'
    return