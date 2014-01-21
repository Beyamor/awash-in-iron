define ['jinn/scenes', "aii/play/levels", "jinn/cameras",
	"jinn/input", "jinn/app", "jinn/debug/definitions",
	"aii/play/entities", "aii/play/control", "jinn/entities/spaces",
	"jinn/canvas", "aii/three", "three"],
	({Scene}, {Level}, cams,\
	input, app, definitionsDebug,\
	{Unit}, control, {EntitySpace},\
	{Canvas}, {SceneRenderer, SceneEntityList, RENDER_SCALE, SceneCamera}, THREE) ->
		ns = {}

		defs = app.definitions
		app.define
			CAMERA_PAN_SPEED:	10

		class KeyCamera extends cams.CameraWrapper
			update: ->
				super()

				dx = dy = 0

				dx -= 1 if input.isDown "pan-left"
				dx += 1 if input.isDown "pan-right"
				dy += 1 if input.isDown "pan-up"
				dy -= 1 if input.isDown "pan-down"

				if dx isnt 0 and dy isnt 0
					dx *= Math.SQRT1_2
					dy *= Math.SQRT1_2

				@x += dx * defs.CAMERA_PAN_SPEED * app.elapsed
				@y += dy * defs.CAMERA_PAN_SPEED * app.elapsed

		class ns.PlayScene extends Scene
			constructor: ->
				super()

				@controlState = control.stateMachine this

			begin: ->
				INFO_PANEL_WIDTH	= 200
				ACTION_PANEL_WIDTH	= app.width - 200
				ACTION_PANEL_HEIGHT	= app.height


				super()

				scene = new THREE.Scene

				camera = new THREE.PerspectiveCamera 75, ACTION_PANEL_WIDTH / ACTION_PANEL_HEIGHT, 0.1, 1000
				scene.add camera
				@camera = camera

				renderer = new THREE.WebGLRenderer
				renderer.setSize ACTION_PANEL_WIDTH, ACTION_PANEL_HEIGHT
				app.container.append renderer.domElement

				@space = new EntitySpace
						camera:		new KeyCamera(
									new SceneCamera camera
						)
						entities:	new SceneEntityList scene
						renderer:	new SceneRenderer scene, renderer, camera

				@infoPanel = $ '<div class="info-panel">'
				app.container.append @infoPanel

				@els = [renderer.domElement, @infoPanel]

				@level = new Level
				@space.add tile for tile in @level.tiles

				@level.grid[3][3].addUnit new Unit
				@level.grid[5][3].addUnit new Unit
				@level.grid[3][5].addUnit new Unit
				@level.grid[5][5].addUnit new Unit

				camera.position.z = 6
				camera.position.x = @level.pixelWidth / 2 * RENDER_SCALE
				camera.position.y = 0 #@level.pixelHeight / 2 * RENDER_SCALE
				camera.rotation.order = "ZYX"
				camera.rotation.x += 0.7

			update: ->
				super()

				definitionsDebug.toggle() if input.pressed "vk_grave"

				@controlState.update()

				if input.pressed "vk_n"
					app.scene = new ns.PlayScene

				if input.isDown "rot-right"
					@camera.rotation.z += 0.1
				else if input.isDown "rot-left"
					@camera.rotation.z -= 0.1

			@properties
				mouseTile:
					get: ->
						# TODO account for camera offset
						@level.pixelToTile input.mouseX, input.mouseY

		return ns
