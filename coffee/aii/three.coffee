define ["jinn/entities/lists", "three"],
	({SimpleEntityList}, THREE) ->
		ns = {}

		class ns.SceneRenderer
			constructor: (@scene, @renderer) ->

			render: (entities, camera) ->
				for entity in entities.list when entity.model?
					entity.model.position.x = entity.x / 100
					entity.model.position.y = entity.y / 100

				@renderer.render @scene, camera

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
