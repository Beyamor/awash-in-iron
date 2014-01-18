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
		]

		input.define
			"pan-left":	"vk_a"
			"pan-right":	"vk_d"
			"pan-up":	"vk_w"
			"pan-down":	"vk_s"

		app.define
			APP_WDITH:	800
			APP_HEIGHT:	600

		app.launch
			id: "game"
			backgroundColor: "#2C2A2E"
			init: ->
				app.scene = new PlayScene
