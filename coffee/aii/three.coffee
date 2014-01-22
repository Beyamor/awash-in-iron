define ["jinn/entities/lists", "three", "jinn/cameras",
	"jinn/util", "jinn/app", "underscore",
	"jinn/app"],
	({SimpleEntityList}, THREE, {Camera},\
	util, {definitions: defs}, _,\
	app) ->
		ns = {}

		ns.RENDER_SCALE = RENDER_SCALE = 1 / 64
		loader		= new THREE.JSONLoader

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
				e.model.addTo @scene if e.model?

			remove: (e) ->
				super e
				e.model.remove() if e.model?

		class ns.Model
			constructor: (geometryOrAsset, materialOrColor) ->
				if _.isString(geometryOrAsset)
					{geometry} = loader.parse app.assets.get geometryOrAsset
				else
					geometry = geometryOrAsset
					
				if _.isString(materialOrColor) or _.isNumber(materialOrColor)
					material = new THREE.MeshLambertMaterial color: materialOrColor, ambient: materialOrColor
				else
					material = materialOrColor

				@mesh = new THREE.Mesh geometry, material

			addTo: (scene) ->
				@remove()
				@scene = scene
				@scene.add @mesh

			remove: ->
				return unless @scene?

				@scene.remove @mesh
				@scene = null

			@delegate
				mesh:	["position", "rotation"]

		class ns.CubeModel extends ns.Model
			constructor: (x, y, z, materialOrColor) ->
				super new THREE.CubeGeometry(x, y, z), materialOrColor

		class CompositeModelPosition
			constructor: (@models) ->

			@properties
				x:
					get: -> if @models.length then @models[0].position.x else 0
					set: (x) -> model.position.x = x for model in @models
				y:
					get: -> if @models.length then @models[0].position.y else 0
					set: (y) -> model.position.y = y for model in @models
				z:
					get: -> if @models.length then @models[0].position.z else 0
					set: (z) -> model.position.z = z for model in @models

		class ns.CompositeModel
			constructor: (@models...) ->
				@position = new CompositeModelPosition @models

			addTo: (scene) ->
				model.addTo scene for model in @models

			remove: ->
				model.remove() for model in @models
		return ns
