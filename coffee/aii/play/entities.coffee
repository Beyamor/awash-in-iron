define ["jinn/entities", "jinn/graphics", "aii/play/mixins",
	"jinn/util"],
	({Entity}, gfx, _,\
	util) ->
		ns = {}

		random = util.random

		class ns.Unit extends Entity
			constructor: (graphic) ->
				graphic or= new gfx.Rect width: 48, height: 48, centered: true, color: "blue"

				super
					graphic:	graphic
					centered:	true
					width:		48
					height:		48
					mixins:
						healthHaver:
							maxHp:		random.any [8..11]
						attacker:
							strength:	random.any [2..10]
						mover:
							speed:		random.any [2..5]

		return ns
