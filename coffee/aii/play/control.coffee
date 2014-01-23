define ["jinn/control/states", "jinn/input", "aii/play/levels",
	"jinn/app"],
	({StateMachine}, input, levels,\
	app) ->
		ns = {}

		defs = app.definitions
		app.define
			MOVE_HIGHLIGHT_COLOR:	"#69a0d1"
			ATTACK_HIGHLIGHT_COLOR:	"#ff0000"

		class ControlState
			constructor: (@scene) ->

			update: ->
				if input.mouseMoved
					@updateInfo()

			updateInfo: ->
				mouseTile = @scene.mouseTile

				if mouseTile? and mouseTile.unit?
					@showUnitInfo mouseTile.unit
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
			begin: ->
				@updateInfo()

			update: ->
				super()

				if input.pressed "mouse-left"
					mouseTile = @scene.mouseTile
					if mouseTile? and mouseTile.unit?
						@scene.selectedUnit = mouseTile.unit
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
					left:	input.mouseX - @menuEl.width()
					top:	input.mouseY - @menuEl.height()

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
				@reachableTiles	= @scene.selectedUnit.tile.neighboursInRadius @scene.selectedUnit.speed, (tile) ->
							tile.isPassable

				for tile in @reachableTiles
					highlight = new levels.TileHighlight tile, defs.MOVE_HIGHLIGHT_COLOR
					@scene.space.add highlight
					@highlights.push highlight

			update: ->
				super()

				if input.pressed "mouse-left"
					mouseTile = @scene.mouseTile
					if mouseTile? and @reachableTiles.contains mouseTile
						mouseTile.addOccupant @scene.selectedUnit
						@scene.controlState.switchTo "default"

				else if input.pressed "mouse-right"
					@scene.controlState.switchTo "default"

			end: ->
				for highlight in @highlights
					highlight.remove()

		class AttackState extends ControlState
			begin: ->
				@highlights	= []
				@hittableTiles	= @scene.selectedUnit.tile.fov @scene.selectedUnit.range, (tile) ->
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
					if selectedTile? and @hittableTiles.contains(selectedTile) and selectedTile.unit?
						@scene.selectedUnit.attack selectedTile.unit
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
