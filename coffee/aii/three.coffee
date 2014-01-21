define ["jinn/entities/lists", "three", "jinn/cameras"],
	({SimpleEntityList}, THREE, {Camera}) ->
		ns = {}

		ns.RENDER_SCALE = RENDER_SCALE = 1 / 64

		class ns.SceneCamera extends Camera
			constructor: (@camera) ->
				@pos = @camera.position

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
