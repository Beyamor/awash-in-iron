define ['jinn/scenes', "aii/play/levels", "jinn/cameras",
	"jinn/input", "jinn/app", "jinn/debug/definitions",
	"aii/play/entities", "aii/play/control", "jinn/entities/spaces",
	"jinn/canvas", "aii/three", "three"],
	({Scene}, {Level}, cams,\
	input, app, definitionsDebug,\
	{Unit}, control, {EntitySpace},\
	{Canvas}, {SceneRenderer, SceneEntityList, RENDER_SCALE, SceneCamera, Renderer}, THREE) ->
		ns = {}

		defs = app.definitions
		app.onLaunch ->
			app.define
				CAMERA_ANGLE:		0.5
				CAMERA_HEIGHT:		7
				CAMERA_PAN_SPEED:	10
				INFO_PANEL_WIDTH:	200
				ACTION_PANEL_WIDTH:	app.width - 200
				ACTION_PANEL_HEIGHT:	app.height

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

				if input.pressed "rot-right"
					@rotation += Math.PI * 2 / 8
				if input.pressed "rot-left"
					@rotation -= Math.PI * 2 / 8

			@delegate
				base:	["rotation"]

		class ns.PlayScene extends Scene
			
			constructor: ->
				super()

				@controlState = control.stateMachine this

			begin: ->


				super()

				scene = new THREE.Scene
				@scene = scene

				camera = new THREE.PerspectiveCamera 75, defs.ACTION_PANEL_WIDTH / defs.ACTION_PANEL_HEIGHT, 0.1, 1000
				scene.add camera
				@camera = camera

				renderer = new Renderer
				renderer.setSize defs.ACTION_PANEL_WIDTH, defs.ACTION_PANEL_HEIGHT
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

				camera.position.x = @level.pixelWidth / 2 * RENDER_SCALE
				camera.position.y = 0
				camera.rotation.order = "ZYX"

				light = new THREE.AmbientLight 0x404040
				scene.add light

				light = new THREE.DirectionalLight 0xd0d0d0
				light.position.set(@level.pixelWidth/2, @level.pixelHeight/2, 10).normalize()
				scene.add light

			update: ->
				super()

				definitionsDebug.toggle() if input.pressed "vk_grave"

				@controlState.update()

				if input.pressed "vk_n"
					app.scene = new ns.PlayScene
								
			@properties
				mouseTile:
					get: ->
						{mouseX, mouseY} = input
						return null if mouseX < 0 or mouseY < 0 or
							mouseX >= defs.ACTION_PANEL_WIDTH or mouseY >= defs.ACTION_PANEL_HEIGHT

						mouseX		= (mouseX - defs.ACTION_PANEL_WIDTH / 2) /
									( defs.ACTION_PANEL_WIDTH / 2)
						mouseY		= (mouseY - defs.ACTION_PANEL_HEIGHT / 2) /
									(defs.ACTION_PANEL_HEIGHT / 2) * -1
						mouseCoords	= new THREE.Vector3 mouseX, mouseY, 0
						projector	= new THREE.Projector
						ray		= projector.pickingRay mouseCoords, @camera
						objects		= ray.intersectObjects @scene.children

						return null unless objects.length?

						for object in objects
							object = object.object
							return object.tile if object.tile?

						return null

		return ns
