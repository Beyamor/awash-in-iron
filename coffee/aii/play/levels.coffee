define ["jinn/util", "jinn/entities", "jinn/graphics"],
	(util, {Entity}, gfx) ->
		ns = {}

		class Tile extends Entity
			@WIDTH:		64
			@HEIGHT:	64

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
			@WIDTH:		18
			@HEIGHT:	18

			constructor: ->
				@tiles	= []
				@grid	= util.array2d ns.Level.WIDTH, ns.Level.HEIGHT, (x, y) =>
						tile = new Tile x, y
						@tiles.push tile
						return tile

			@properties
				pixelWidth:
					get: -> ns.Level.WIDTH * Tile.WIDTH

				pixelHeight:
					get: -> ns.Level.HEIGHT * Tile.HEIGHT

		return ns
