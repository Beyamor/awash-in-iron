define ["jinn/entities", "jinn/graphics", "aii/play/mixins",
	"jinn/util", "three", "jinn/app"],
	({Entity}, gfx, _,\
	util, THREE, app) ->
		ns = {}

		defs	= app.definitions
		random	= util.random

		class ns.Unit extends Entity
			constructor: ->
				@maxHp		= random.any [8..11]
				@strength	= random.any [2..10]
				@speed		= random.any [2..5]
				@range		= random.any [2..7]

				super
					centered:	true
					width:		0.75
					height:		0.75
					mixins:
						healthHaver:	true
						attacker:	true
						defender:	true

				#geometry	= new THREE.CubeGeometry 0.75, 0.75, 2
				loader		= new THREE.JSONLoader
				{geometry}	= loader.parse app.assets.get "simple-mecha"
				material	= new THREE.MeshLambertMaterial color: "grey", ambient: "grey"
				@model		= new THREE.Mesh geometry, material

				@model.position.z = 0.6
				@model.rotation.x = Math.PI / 2

			die: ->
				@tile.removeUnit() if @tile?

		return ns
