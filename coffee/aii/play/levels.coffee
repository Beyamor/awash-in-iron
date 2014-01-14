define ["jinn/util", "jinn/entities", "jinn/graphics"],
	(util, {Entity}, gfx) ->
		ns = {}

		terrains = {
			dirt:
				color:		"#E0D294"
				passable:	true

			rock:
				color:		"#47473C"
				passable:	false
		}

		class Tile extends Entity
			@WIDTH:		64
			@HEIGHT:	64

			constructor: (@terrain, x, y) ->
				super
					x:		x * Tile.WIDTH
					y:		y * Tile.HEIGHT
					width:		Tile.WIDTH
					height:		Tile.HEIGHT
					layer:		200
					graphic:	new gfx.Rect
								width:	Tile.WIDTH
								height:	Tile.HEIGHT
								color:	@terrain.color

			addUnit: (unit) ->
				throw new Error "Tiles already contains a unit" if @unit?

				unit.tile.removeUnit() if unit.tile?

				unit.tile	= this
				@unit		= unit
				@scene.add unit if @scene?

				unit.centerX = @centerX
				unit.centerY = @centerY

			added: ->
				@scene.add @unit if @unit?

			removeUnit: ->
				return unless @unit?

				@unit.world.remove @unit if @unit.world?
				@unit.tile	= null
				@unit		= null

			remove: ->
				@world.remove unit if @unit?

			@properties
				neighbours:
					get: ->
						unless @_neighbours?
							@_neighbours = (neighbour for neighbour in [@north, @south, @east, @west]\
										when neighbour?)
						return @_neighbours

		class ns.TileHighlight extends Entity
			@WIDTH:		64
			@HEIGHT:	64

			constructor: (x, y) ->
				super
					x:		x * Tile.WIDTH
					y:		y * Tile.HEIGHT
					width:		Tile.WIDTH
					height:		Tile.HEIGHT
					layer:		200
					graphic:	new gfx.Rect
								width:		Tile.WIDTH
								height:		Tile.HEIGHT
								color:		"rgba(119, 129, 237, 0.5)"
								visible:	false

			show: ->
				@isShowing		= true
				@graphic.visible	= true
				@reposition()

			hide: ->
				@isShowing		= false
				@graphic.visible	= false

			reposition: ->
				tile		= @scene.mouseTile
				@centerX	= tile.centerX
				@centerY	= tile.centerY

			update: ->
				super()

				@reposition() if @isShowing
					

		class ns.Level
			@WIDTH:		16
			@HEIGHT:	16

			constructor: ->
				terrainOptions = []
				terrainOptions.push terrains.dirt for i in [0...10]
				terrainOptions.push terrains.rock

				@tiles	= []
				@grid	= util.array2d ns.Level.WIDTH, ns.Level.HEIGHT, (x, y) =>
						tile = new Tile util.random.any(terrainOptions), x, y
						@tiles.push tile
						return tile

				util.array2d.each @grid, (i, j, tile) =>
					tile.north	= @grid[i][j-1] if j > 0
					tile.south	= @grid[i][j+1] if j < ns.Level.HEIGHT-1
					tile.east	= @grid[i-1][j] if i > 0
					tile.west	= @grid[i+1][j] if i < ns.Level.WIDTH-1

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
