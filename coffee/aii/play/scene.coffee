define ['jinn/scenes', "aii/play/levels", "jinn/cameras",
	"jinn/input", "jinn/app", "jinn/debug/definitions",
	"aii/play/entities"],
	({Scene}, {Level}, {CameraWrapper, BoundedCamera},\
	input, app, definitionsDebug,\
	{Unit}) ->
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
			begin: ->
				super()

				@level = new Level
				@add tile for tile in @level.tiles

				@camera = new BoundedCamera {left: 0, right: @level.pixelWidth, top: 0, bottom: @level.pixelWidth},
						new KeyCamera @camera

				@level.grid[3][3].addUnit new Unit
				@level.grid[5][3].addUnit new Unit

			update: ->
				super()

				definitionsDebug.toggle() if input.pressed "vk_grave"

				if input.mouseMoved
					@activeTile.highlight.hide() if @activeTile?
					@activeTile = @mouseTile
					@activeTile.highlight.show() if @selectedUnit?

				if input.pressed 'mouse-left'
					if @selectedUnit?
						unless @mouseTile.unit?
							@mouseTile.addUnit @selectedUnit
							@selectedUnit = null
							@activeTile.highlight.hide() if @activeTile?
					else
						@selectedUnit = @mouseTile.unit
						@activeTile.highlight.show() if @activeTile?

			@properties
				mouseTile:
					get: -> @level.pixelToTile input.mouseX + @camera.x, input.mouseY + @camera.y


		return ns
