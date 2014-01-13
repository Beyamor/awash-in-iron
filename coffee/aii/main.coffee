define ['jinn/app', 'jinn/debug', 'jinn/input'],
	(app, debug, input) ->
		debug.config
			enabled: true
			types:
				fps: true

		app.assets = [
		]

		app.launch
			width: 800
			height: 600
			id: "game"
			backgroundColor: "#2C2A2E"
			init: ->
				alert "hello world"
