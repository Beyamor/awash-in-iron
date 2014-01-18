define ['jinn/scenes', "aii/play/levels", "jinn/cameras",
	"jinn/input", "jinn/app", "jinn/debug/definitions",
	"aii/play/entities", "aii/play/control", "jinn/entities/spaces",
	"jinn/canvas"],
	({Scene}, {Level}, {CameraWrapper, BoundedCamera},\
	input, app, definitionsDebug,\
	{Unit}, control, {EntitySpace},\
	{Canvas}) ->
		ns = {}

		defs = app.definitions
		app.define
			CAMERA_PAN_SPEED:	700

		class KeyCamera extends CameraWrapper
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
				super()

				@canvas	= new Canvas width: defs.APP_WDITH, height: defs.APP_HEIGHT
				@el	= @canvas.el
				app.container.append @canvas.el

				@level = new Level

				@space = new EntitySpace canvas: @canvas
				@space.add tile for tile in @level.tiles

				@space.camera = new BoundedCamera {left: 0, right: @level.pixelWidth,\
									top: 0, bottom: @level.pixelWidth},
						new KeyCamera @space.camera

				@level.grid[3][3].addUnit new Unit
				@level.grid[5][3].addUnit new Unit
				@level.grid[3][5].addUnit new Unit
				@level.grid[5][5].addUnit new Unit

			update: ->
				super()

				definitionsDebug.toggle() if input.pressed "vk_grave"

				@controlState.update()

				if input.pressed "vk_n"
					app.scene = new ns.PlayScene

			@properties
				mouseTile:
					get: -> @level.pixelToTile input.mouseX + @space.camera.x, input.mouseY + @space.camera.y


		return ns
