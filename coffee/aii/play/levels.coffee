define ["jinn/util", "jinn/entities", "jinn/graphics",
	"jinn/app", "aii/three", "three",
	"aii/play/entities"],
	(util, {Entity}, gfx,\
	app, {CubeModel}, THREE,\
	{Unit}) ->
		ns = {}

		defs = app.definitions

		class Tile extends Entity
			@WIDTH:		1
			@HEIGHT:	1

			constructor: (@level, @gridX, @gridY) ->
				super
					x:		@gridX
					y:		@gridY
					width:		Tile.WIDTH
					height:		Tile.HEIGHT
					centered:	true

				@model = new CubeModel @width, @height, 1, "#E0D294"
				@model.mesh.tile = this
				@model.position.z = -0.5

			addOccupant: (occupant) ->
				throw new Error "Tile already full" if @occupant?

				occupant.tile.removeOccupant() if occupant.tile?

				occupant.tile = this
				@occupant = occupant
				@space.add occupant if @space?

				occupant.x = @x
				occupant.y = @y

			added: ->
				@space.add @occupant if @occupant?

			removeOccupant: ->
				return unless @occupant?

				@occupant.space.remove @occupant if @occupant.space?
				@occupant.tile	= null
				@occupant	= null

			remove: ->
				@world.remove occupant if @occupant?

			neighboursInRadius: (range, filter) ->
				return [] if range <= 0

				filter or= -> true

				closedList	= []
				openList	= (neighbour for neighbour in @neighbours when filter neighbour)

				while range > 0
					nextOpenList = []
					for open in openList
						for next in open.neighbours when filter next
							continue if next is this
							continue if nextOpenList.indexOf(next)	isnt -1
							continue if openList.indexOf(next)	isnt -1
							continue if closedList.indexOf(next)	isnt -1
							nextOpenList.push next
						closedList.push open
					openList = nextOpenList
					--range

				return closedList

			fov: (radius, isBlocker) ->
				#isBlocker or= -> false
				#doFOV @level, @gridX, @gridY, radius, isBlocker
				fov		= @neighboursInRadius radius
				blocked		= []

				for blocker in fov when isBlocker blocker
					blockType	= isBlocker blocker
					dx		= blocker.gridX - @gridX
					dy		= blocker.gridY - @gridY
					blockerDistance	= Math.abs(dx) + Math.abs(dy)

					# along east axis
					if dy is 0 and dx > 0
						x1	= blocker.left
						y1	= blocker.top
						x2	= blocker.left
						y2	= blocker.bottom

					# along west axis
					else if dy is 0 and dx < 0
						x1	= blocker.right
						y1	= blocker.bottom
						x2	= blocker.right
						y2	= blocker.top

					# along south axis
					else if dx is 0 and dy > 0
						x1	= blocker.right
						y1	= blocker.top
						x2	= blocker.left
						y2	= blocker.top

					# along north axis
					else if dx is 0 and dy < 0
						x1	= blocker.left
						y1	= blocker.bottom
						x2	= blocker.right
						y2	= blocker.bottom

					# north-east
					else if dx > 0 and dy < 0
						x1	= blocker.left
						y1	= blocker.top
						x2	= blocker.right
						y2	= blocker.bottom

					# north-west
					else if dx < 0 and dy < 0
						x1	= blocker.left
						y1	= blocker.bottom
						x2	= blocker.right
						y2	= blocker.top

					# south-east
					else if dx > 0 and dy > 0
						x1	= blocker.right
						y1	= blocker.top
						x2	= blocker.left
						y2	= blocker.bottom

					# south-west
					else
						x1	= blocker.right
						y1	= blocker.bottom
						x2	= blocker.left
						y2	= blocker.top
					
					margin	= 0.01
					lower	= (Math.atan2 y1 - @centerY, x1 - @centerX)
					upper	= (Math.atan2 y2 - @centerY, x2 - @centerX)

					if blockType is "partial"
						lower += margin
						upper -= margin
					else
						lower -= margin
						upper += margin

					for tile in fov when tile isnt blocker
						distance = Math.abs(tile.gridX - @gridX) + Math.abs(tile.gridY - @gridY)
						continue if distance <= blockerDistance

						continue if blocked.contains tile

						theta = Math.atan2 tile.centerY - @centerY, tile.centerX - @centerX
						if util.isBetweenAngles theta, lower, upper
							blocked.push tile

				fov.remove(tile) for tile in blocked
				return fov

			@properties
				neighbours:
					get: ->
						unless @_neighbours?
							@_neighbours = (neighbour for neighbour in [@north, @south, @east, @west]\
										when neighbour?)
						return @_neighbours.concat()

				isPassable:
					get: -> not @occupant?

				unit:
					get: -> @occupant if @occupant instanceof Unit

				isOccupied:
					get: -> !! @occupant

		class ns.TileHighlight extends Entity
			constructor: (tile, color) ->
				margin = 0.1

				super
					x:		tile.x
					y:		tile.y
					width:		tile.width - margin
					height:		tile.height - margin
					centered:	true

				@x = tile.x
				@y = tile.y

				@model = new CubeModel @width, @height, 1.1, color
				@model.position.z -= 0.5

		class ns.Level
			@WIDTH:		16
			@HEIGHT:	16

			constructor: ->
				@tiles	= []
				@grid	= util.array2d ns.Level.WIDTH, ns.Level.HEIGHT, (x, y) =>
						tile = new Tile this, x, y
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

				x = util.clamp x, 0, ns.Level.WIDTH - 1
				y = util.clamp y, 0, ns.Level.HEIGHT - 1

				return @grid[x][y]

			@properties
				pixelWidth:
					get: -> ns.Level.WIDTH * Tile.WIDTH

				pixelHeight:
					get: -> ns.Level.HEIGHT * Tile.HEIGHT

		return ns
