define ['jinn/scenes', "aii/play/levels", "jinn/cameras",
	"jinn/input", "jinn/app", "jinn/debug/definitions",
	"aii/play/entities", "aii/play/control", "jinn/entities/spaces",
	"jinn/canvas", "aii/three", "three"],
	({Scene}, {Level}, cams,\
	input, app, definitionsDebug,\
	{Unit}, control, {EntitySpace},\
	{Canvas}, {SceneRenderer, SceneEntityList, RENDER_SCALE}, THREE) ->
		ns = {}

		defs = app.definitions
		app.define
			CAMERA_PAN_SPEED:	700

		class KeyCamera extends cams.CameraWrapper
			update: ->
				super()

				dx = dy = 0

				dx -= 1 if input.isDown "pan-left"
				dx += 1 if input.isDown "pan-right"
				dy -= 1 if input.isDown "pan-up"
				dy += 1 if input.isDown "pan-down"

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

				if defs.RENDER_3D
					scene = new THREE.Scene

					camera = new THREE.PerspectiveCamera 75, ACTION_PANEL_WIDTH / ACTION_PANEL_HEIGHT, 0.1, 1000

					renderer = new THREE.WebGLRenderer
					renderer.setSize ACTION_PANEL_WIDTH, ACTION_PANEL_HEIGHT
					app.container.append renderer.domElement

					@space = new EntitySpace
							camera:		camera
							entities:	new SceneEntityList scene
							renderer:	new SceneRenderer scene, renderer
					
				else
					canvas = new Canvas width: ACTION_PANEL_WIDTH, height: ACTION_PANEL_HEIGHT
					app.container.append canvas.el

					@space = new EntitySpace
							canvas:	canvas

				@infoPanel = $ '<div class="info-panel">'
				app.container.append @infoPanel

				if defs.RENDER_3D
					@els = [renderer.domElement, @infoPanel]
				else
					@els = [canvas.el, @infoPanel]

				@level = new Level
				@space.add tile for tile in @level.tiles

				@level.grid[3][3].addUnit new Unit
				@level.grid[5][3].addUnit new Unit
				@level.grid[3][5].addUnit new Unit
				@level.grid[5][5].addUnit new Unit

				if defs.RENDER_3D
					camera.position.z = 20
					camera.position.x = @level.pixelWidth / 2 * RENDER_SCALE
					camera.position.y = @level.pixelHeight / 2 * RENDER_SCALE
				else
					@space.camera = new cams.BoundedCamera {left: 0, right: @level.pixelWidth,\
										top: 0, bottom: @level.pixelWidth},
								new KeyCamera @space.camera

			update: ->
				super()

				definitionsDebug.toggle() if input.pressed "vk_grave"

				@controlState.update()

				if input.pressed "vk_n"
					app.scene = new ns.PlayScene

				if input.isDown "mouse-left"
					@space.camera.rotation.y += (input.mouseX - input.prevMouseX) / 1000
					@space.camera.rotation.x += (input.mouseY - input.prevMouseY) / 1000

			@properties
				mouseTile:
					get: ->
						if defs.RENDER_3D
							# TODO account for camera offset
							@level.pixelToTile input.mouseX, input.mouseY
						else
							@level.pixelToTile input.mouseX + @space.camera.x,
										input.mouseY + @space.camera.y

		return ns
