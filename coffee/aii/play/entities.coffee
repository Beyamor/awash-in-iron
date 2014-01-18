define ["jinn/entities", "jinn/graphics", "aii/play/mixins",
	"jinn/util"],
	({Entity}, gfx, _,\
	util) ->
		ns = {}

		random = util.random

		class ns.Unit extends Entity
			constructor: (graphic) ->
				graphic or= new gfx.Rect width: 48, height: 48, centered: true, color: "blue"

				@maxHp		= random.any [8..11]
				@strength	= random.any [2..10]
				@speed		= random.any [2..5]

				super
					graphic:	graphic
					centered:	true
					width:		48
					height:		48
					mixins:
						healthHaver:	true
						attacker:	true
						defender:	true
						mover:		true

			die: ->
				@tile.removeUnit() if @tile?

		return ns
