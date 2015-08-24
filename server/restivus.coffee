Api = new Restivus
	useDefaultAuth:	true
	prettyJson:	true

Api.addRoute 'avatars/:id', authRequired: false,
	get: ->
		uid = @urlParams.id.replace('.png', '')
		result = Avatars.findOne {'username': uid}
		if result?
			img = new Buffer result.avatar.replace('data:image/png;base64,', ''), 'base64'
			this.response.writeHead(200, {'Content-Type': 'image/png', 'Content-Length': img.length, 'cache-control': 'private, max-age=600'})
			this.response.write(img)
			this.done()
		else
			this.response.write('')
			this.done()