define ["jinn/entities/lists", "three"],
	({SimpleEntityList}, THREE) ->
		ns = {}

		class ns.SceneRenderer
			constructor: (@renderer) ->

			render: (entities, camera) ->
				renderer.render @scene, camera

		class ns.SceneEntityList
			constructor: (@base) ->
				@scene = new THREE.Scene
				@base or= new SimpleEntityList

			add: (e) ->
				@base.add e
				@scene.add e.model if e.model?

			remove: (e) ->
				@base.remove e
				@scene.remove e.model if e.model?

		return ns
