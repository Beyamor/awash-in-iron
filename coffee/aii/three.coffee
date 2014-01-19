define ["jinn/entities/lists", "three"],
	({SimpleEntityList}, THREE) ->
		ns = {}

		class ns.SceneRenderer
			constructor: (@renderer) ->

			render: (entities, camera) ->
				for entity in entities.list when entity.model?
					entity.model.position.x = entity.x / 100
					entity.model.position.y = entity.y / 100
					"do nothing"

				@renderer.render entities.scene, camera

		class ns.SceneEntityList extends SimpleEntityList
			constructor: ->
				super()
				@scene = new THREE.Scene

			add: (e) ->
				super e
				@scene.add e.model if e.model?

			remove: (e) ->
				super e
				@scene.remove e.model if e.model?

		return ns
