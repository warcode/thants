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
			img = new Buffer 'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAADsUlEQVR4Ae2bA9QsRxCFK7Zt27Zt27Zt27bNo9h2dvveWsW27Wy6YydTPfPv637vO+ceL271bGlmpS+oNZtTk9zIkft5nQXyRkc6kO96fe71PIAHQF4N1RNJ7g5g4auvvnoQSZVHnnlmeEduAdVHQXaNeovkmUkFo95ozEPykp9Ptlui3oLqAc1mc3DpF3niiSeGhuppBmNF1VLVuaVfQlVnBdmxmjLoe0ee2ul0hpNe0u12Bya5L8hv4k2ZpP7KG0F6RcjYcQbiRfLunuQFAFtVY8og1Sv81TiQ9BVOdfFqL3uDgMP76uSnAPlh1YYM+grAuFI1JK+P/KLvOfJBABeHug5gN6ie43U/yA8i3/uEqs1PGUqQ8ct948gjH3rooaHkH/DJbFhHHgXya+NnfOarwqhSFY68wJipX/earmCgnzN+1kFVNTvjWU/GObeEIdfMYUy0D1WV/LY2mSdPibji9jeUxHeq+v2fbEl4YUaI+MyJLUGv1+sjVvH7v81Qm4+RSEIQi35umE2kbEC+XPCLfBdOsITPfciQCFeUsjHU6BslkrvvvntQkJ8UDUDYSVTyEzBnfnvlmduYAyasov/frsjSoozhBOTZll1BJdNhmP1B3vt/vgDJFUoou6say+6D4qmyGar9RwI6WCLxJzipdeAiuVnVu7/BoHooydf/9OHPOtWVSjj5aUG+ZpwFPu/TDZGqjuE1a7vdHqWsjTLI9yO2Q/tKqgBYLnKVfmfIU6maXx/ktzH3DHzeGFNSxKluGSpH1IpcdfFUze+SwC7QgHHUNeiE0HClaP6oWPOO3DPlhBdj/luobiIpUqvVRgP5boT5L35us9ME5GUR5j8kOb+kCsmlIsy/0Wg0ZpBUeeGFF4YE8KKxzL1IcmJJmbrqMsaTfxnARJI6AM4wmH9TVSeRHAiXsam9zYHwdFfhXl/1IskFAKMb9vpzSy4456YpWu8TmOsLP1DRLaCbJSfCzY1Cd5VV95LcANkqsNebUnKD5Eb/MwA1yQXDrbXPVXV6yZUwD5A84h+Wn23XaCwkSWK4uxRuoADYm+Q2qrpYSJTSfzCAAYAczGs6r7W9tvCax2v4/sH4wMHwP+wEv/M6xWuEXM0P/T+f9XkDOTZCKPaEKbyGzMn8ooZt0H45BeBQQwDuyCkANxsC8EFOAbjIEICncgrAdoYAXJ5TACYzPPqyZm5lcMMC5s/KtRna0eujfzH+jdcZXoPn3A6P7nWM1y9/kPrE61Gvs7ymkB7wAxAyZqcJihEZAAAAAElFTkSuQmCC', 'base64'
			this.response.writeHead(200, {'Content-Type': 'image/png', 'Content-Length': img.length, 'cache-control': 'private, max-age=300'})
			this.response.write(img)
			this.done()