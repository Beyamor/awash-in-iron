define ["jinn/util", "jinn/entities", "jinn/graphics"],
	(util, {Entity}, gfx) ->
		ns = {}

		class Tile extends Entity
			@WIDTH:		48
			@HEIGHT:	48

			constructor: (x, y) ->
				super
					x:		x * Tile.WIDTH
					y:		y * Tile.HEIGHT
					graphic:	new gfx.Rect(
								Tile.WIDTH,
								Tile.HEIGHT,
								util.random.choose "red", "yellow", "blue"
					)

		class ns.Level
			@WIDTH:		24
			@HEIGHT:	24

			constructor: ->
				@tiles	= []
				@grid	= util.array2d ns.Level.WIDTH, ns.Level.HEIGHT, (x, y) =>
						tile = new Tile x, y
						@tiles.push tile
						return tile

		return ns
