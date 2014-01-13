define ['jinn/app', 'jinn/debug', 'jinn/input',
	'aii/play/scene'],
	(app, debug, input,\
	{PlayScene}) ->
		debug.config
			enabled: true
			flags:
				fps: true

		app.assets = [
		]

		app.launch
			width: 800
			height: 600
			id: "game"
			backgroundColor: "#2C2A2E"
			init: ->
				app.scene = new PlayScene
