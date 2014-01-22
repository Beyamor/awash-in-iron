define ["jinn/entities/lists", "three", "jinn/cameras",
	"jinn/util", "jinn/app"],
	({SimpleEntityList}, THREE, {Camera},\
	util, {definitions: defs}) ->
		ns = {}

		ns.RENDER_SCALE = RENDER_SCALE = 1 / 64

		class CameraPositionWrapper
			constructor: (@camera) ->

			@properties
				theta:
					get: ->
						@camera.rotation.z

				x:
					get: ->
						@camera.position.x * Math.cos(-@theta) + @camera.position.y * -Math.sin(-@theta)

					set: (x) ->
						oldY = @y
						@camera.position.x = x * Math.cos(@theta) + oldY * -Math.sin(@theta)
						@camera.position.y = x * Math.sin(@theta) + oldY * Math.cos(@theta)
				y:
					get: ->
						@camera.position.x * Math.sin(-@theta) + @camera.position.y * Math.cos(-@theta)

					set: (y) ->
						oldX = @x
						@camera.position.x = oldX * Math.cos(@theta) + y * -Math.sin(@theta)
						@camera.position.y = oldX * Math.sin(@theta) + y * Math.cos(@theta)

		class ns.SceneCamera extends Camera
			constructor: (@camera) ->
				@pos = new CameraPositionWrapper @camera

			update: ->
				@camera.position.z	= defs.CAMERA_HEIGHT
				@camera.rotation.x	= defs.CAMERA_ANGLE

			@properties
				rotation:
					get: -> @camera.rotation.z
					set: (value) -> @camera.rotation.z = value

		class ns.SceneRenderer
			constructor: (@scene, @renderer, @camera) ->

			render: (entities, _) ->
				entities.each (entity) ->
					return unless entity.model?
					entity.model.position.x = entity.x# * RENDER_SCALE
					entity.model.position.y = entity.y# * RENDER_SCALE

				@renderer.render @scene, @camera

		class ns.SceneEntityList extends SimpleEntityList
			constructor: (@scene) ->
				super()

			add: (e) ->
				super e
				@scene.add e.model if e.model?

			remove: (e) ->
				super e
				@scene.remove e.model if e.model?

		return ns
