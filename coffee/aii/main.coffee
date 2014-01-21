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

		app.templates = [
			["click-off-panel", "templates/click-off-panel.html"]
			["action-select-menu", "templates/play/action-select-menu.html"]
			["unit-info", "templates/play/unit-info.html"]
		]

		input.define
			"pan-left":	"vk_a"
			"pan-right":	"vk_d"
			"pan-up":	"vk_w"
			"pan-down":	"vk_s"

		app.define
			RENDER_3D:	true

		app.launch
			id: "game"
			width: 800
			height: 600
			backgroundColor: "#2C2A2E"
			init: ->
				app.scene = new PlayScene
