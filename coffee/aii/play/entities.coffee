define ["jinn/entities", "jinn/graphics"],
	({Entity}, gfx) ->
		ns = {}

		class ns.Unit extends Entity
			constructor: (graphic) ->
				graphic or= new gfx.Rect width: 48, height: 48, centered: true, color: "blue"

				super
					graphic:	graphic
					centered:	true

		return ns
