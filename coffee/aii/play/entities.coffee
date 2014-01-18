define ["jinn/entities", "jinn/graphics", "aii/play/mixins",
	"jinn/util"],
	({Entity}, gfx, _,\
	util) ->
		ns = {}

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
							maxHp:	util.random.intInRange 8, 11

		return ns
