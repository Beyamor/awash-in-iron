define ['jinn/scenes', "aii/play/levels", "jinn/cameras",
	"jinn/input"],
	({Scene}, {Level}, {CameraWrapper},\
	input) ->
		ns = {}

		class DraggedCamera extends CameraWrapper
			@isDragging = false

			update: ->
				super()

				if input.pressed "mouse-left"
					@isDragging	= true
					@prevX		= input.mouseX
					@prevY		= input.mouseY

				if @isDragging
					dx	= input.mouseX - @prevX
					dy	= input.mouseY - @prevY

					@base.x -= dx
					@base.y -= dy

					@prevX	= input.mouseX
					@prevY	= input.mouseY

				if input.released "mouse-left"
					@isDragging = false

		class ns.PlayScene extends Scene
			begin: ->
				super()

				@level = new Level
				@add tile for tile in @level.tiles

				@camera = new DraggedCamera @camera

		return ns
