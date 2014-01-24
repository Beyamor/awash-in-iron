define ["jinn/entities", "jinn/graphics", "aii/play/mixins",
	"jinn/util", "three", "jinn/app",
	"aii/three"],
	({Entity}, gfx, _,\
	util, THREE, app, \
	{Model}) ->
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
					mixins:
						healthHaver:	true
						attacker:	true
						defender:	true

				@model			= new Model "simple-mecha", "slateblue"
				@model.rotation.x	= Math.PI / 2

			die: ->
				@tile.removeOccupant() if @tile?

		class ns.Boulder extends Entity
			constructor: ->
				super
					centered:	true
					width:		0.75

				@model			= new Model "boulder", "grey"
				@model.rotation.order	= "ZYX"
				@model.rotation.x	= Math.PI / 2
				@model.rotation.z	= util.random.angle

		return ns
