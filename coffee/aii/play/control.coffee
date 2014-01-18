define ["jinn/control/states", "jinn/input", "aii/play/levels",
	"jinn/app"],
	({StateMachine}, input, levels,\
	app) ->
		ns = {}

		defs = app.definitions
		app.define
			MOVE_HIGHLIGHT_COLOR:	"mediumSlateBlue"
			ATTACK_HIGHLIGHT_COLOR:	"red"

		class ControlState
			constructor: (@scene) ->

			update: ->
				if input.mouseMoved
					if @scene.mouseTile.unit?
						@showUnitInfo @scene.mouseTile.unit
					else if @scene.selectedUnit?
						@showUnitInfo @scene.selectedUnit
					else
						@removeInfo()

			showUnitInfo: (unit) ->
				@removeInfo()
				@scene.infoPanel.html app.templates.compile('unit-info', unit)

			removeInfo: ->
				@scene.infoPanel.empty()

		class DefaultState extends ControlState
			update: ->
				super()

				if input.pressed "mouse-left"
					if @scene.mouseTile.unit?
						@scene.selectedUnit = @scene.mouseTile.unit
						@scene.controlState.switchTo "selectAction"

		class SelectActionState extends ControlState
			begin: ->
				options = [
					{label: "Move",		state: "move"}
					{label: "Attack",	state: "attack"}
					{label: "Cancel",	state: "default"}
				]

				@cancelEl = $(app.templates.compile "click-off-panel")
				app.container.append @cancelEl
				@cancelEl.click => @scene.controlState.switchTo "default"

				@menuEl = $(app.templates.compile "action-select-menu", options)
				app.container.append @menuEl

				@menuEl.children().each (_, el) =>
					$(el).click => @scene.controlState.switchTo $(el).data("state")

				@repositionMenu()

			repositionMenu: ->
				@menuEl.offset
					left:	@scene.selectedUnit.tile.left - @scene.space.camera.left
					top:	@scene.selectedUnit.tile.top - @scene.space.camera.top

			update: ->
				super()

				if input.pressed "mouse-right"
					@scene.controlState.switchTo "default"

			end: ->
				@cancelEl.remove()
				@menuEl.remove()

		class MoveState extends ControlState
			begin: ->
				@highlights	= []
				@reachableTiles	= @scene.selectedUnit.tile.neighboursInRadius 3, (tile) ->
							tile.isPassable

				for tile in @reachableTiles
					highlight = new levels.TileHighlight tile, defs.MOVE_HIGHLIGHT_COLOR
					@scene.space.add highlight
					@highlights.push highlight

			update: ->
				super()

				if input.pressed "mouse-left"
					if @reachableTiles.contains @scene.mouseTile
						@scene.mouseTile.addUnit @scene.selectedUnit
						@scene.controlState.switchTo "default"

				else if input.pressed "mouse-right"
					@scene.controlState.switchTo "default"

			end: ->
				for highlight in @highlights
					highlight.remove()

		class AttackState extends ControlState
			begin: ->
				@highlights	= []
				@hittableTiles	= @scene.selectedUnit.tile.fov 5, (tile) ->
							if tile.unit?
								"partial"
							else if not tile.isPassable
								"full"

				for tile in @hittableTiles
					highlight = new levels.TileHighlight tile, defs.ATTACK_HIGHLIGHT_COLOR
					@scene.space.add highlight
					@highlights.push highlight

			update: ->
				super()

				if input.pressed "mouse-left"
					selectedTile = @scene.mouseTile
					if @hittableTiles.contains(selectedTile) and selectedTile.unit?
						selectedTile.removeUnit()
						@scene.controlState.switchTo "default"

				else if input.pressed "mouse-right"
					@scene.controlState.switchTo "default"

			end: ->
				for highlight in @highlights
					highlight.remove()

		ns.stateMachine = (scene) ->
			return new StateMachine
				initial: "default"
				states:
					default:	new DefaultState scene
					move:		new MoveState scene
					selectAction:	new SelectActionState scene
					attack:		new AttackState scene

		return ns
