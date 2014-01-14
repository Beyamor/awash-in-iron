define ["jinn/util", "jinn/entities", "jinn/graphics"],
	(util, {Entity}, gfx) ->
		ns = {}

		class Tile extends Entity
			@WIDTH:		64
			@HEIGHT:	64

			constructor: (x, y) ->
				tile = new gfx.Rect
						width:	Tile.WIDTH
						height:	Tile.HEIGHT
						color:	util.random.choose "#E0D294", "#E3D7A1", "#F0E2A3"

				@highlight = new gfx.Rect
						width:		Tile.WIDTH
						height:		Tile.HEIGHT
						color:		"rgba(119, 129, 237, 0.5)"
						visible:	false

				super
					x:		x * Tile.WIDTH
					y:		y * Tile.HEIGHT
					width:		Tile.WIDTH
					height:		Tile.HEIGHT
					layer:		200
					graphic:	new gfx.GraphicsList(tile, @highlight)

			addUnit: (unit) ->
				throw new Error "Tiles already contains a unit" if @unit?

				unit.tile.removeUnit() if unit.tile?

				unit.tile	= this
				@unit		= unit
				@scene.add unit if @scene?

				unit.x = @centerX
				unit.y = @centerY

			added: ->
				@scene.add @unit if @unit?

			removeUnit: ->
				return unless @unit?

				unit.world.remove unit if unit.world?
				unit.tile	= null
				@unit		= null

			remove: ->
				@world.remove unit if @unit?

		class ns.Level
			@WIDTH:		18
			@HEIGHT:	18

			constructor: ->
				@tiles	= []
				@grid	= util.array2d ns.Level.WIDTH, ns.Level.HEIGHT, (x, y) =>
						tile = new Tile x, y
						@tiles.push tile
						return tile

			pixelToTile: (pixelX, pixelY) ->
				x = Math.floor(pixelX / Tile.WIDTH)
				y = Math.floor(pixelY / Tile.HEIGHT)

				return @grid[x][y]

			@properties
				pixelWidth:
					get: -> ns.Level.WIDTH * Tile.WIDTH

				pixelHeight:
					get: -> ns.Level.HEIGHT * Tile.HEIGHT

		return ns
