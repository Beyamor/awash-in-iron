define ["jinn/entities", "jinn/graphics", "aii/play/mixins",
	"jinn/util", "three", "jinn/app"],
	({Entity}, gfx, _,\
	util, THREE, app) ->
		ns = {}

		defs	= app.definitions
		random	= util.random

		class ns.Unit extends Entity
			constructor: (graphic) ->
				@maxHp		= random.any [8..11]
				@strength	= random.any [2..10]
				@speed		= random.any [2..5]
				@range		= random.any [2..7]

				super
					graphic:	graphic
					centered:	true
					width:		0.75
					height:		0.75
					mixins:
						healthHaver:	true
						attacker:	true
						defender:	true

				geometry	= new THREE.CubeGeometry 0.75, 0.75, 2
				material	= new THREE.MeshBasicMaterial color: "blue"
				@model		= new THREE.Mesh geometry, material

			die: ->
				@tile.removeUnit() if @tile?

		return ns
