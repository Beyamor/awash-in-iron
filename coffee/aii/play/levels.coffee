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
					layer:		200
					graphic:	new gfx.Rect
								width:	Tile.WIDTH
								height:	Tile.HEIGHT
								color:	util.random.choose "#E0D294", "#E3D7A1", "#F0E2A3"

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
