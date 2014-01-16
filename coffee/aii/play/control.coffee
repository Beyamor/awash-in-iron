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

		class DefaultState extends ControlState
			update: ->
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
					left:	@scene.selectedUnit.tile.left - @scene.camera.left
					top:	@scene.selectedUnit.tile.top - @scene.camera.top

			update: ->
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
					@scene.add highlight
					@highlights.push highlight

			update: ->
				if input.pressed "mouse-left"
					if @reachableTiles.contains @scene.mouseTile
						@scene.mouseTile.addUnit @scene.selectedUnit
						@scene.controlState.switchTo "default"

				if input.pressed "mouse-right"
					@scene.controlState.switchTo "default"

			end: ->
				for highlight in @highlights
					@scene.remove highlight

		class AttackState extends ControlState
			begin: ->
				@highlights	= []
				@hittableTiles	= @scene.selectedUnit.tile.fov 5, (tile) ->
							tile.unit? or not tile.isPassable

				for tile in @hittableTiles
					highlight = new levels.TileHighlight tile, defs.ATTACK_HIGHLIGHT_COLOR
					@scene.add highlight
					@highlights.push highlight

			update: ->
				if input.pressed "mouse-right"
					@scene.controlState.switchTo "default"

			end: ->
				for highlight in @highlights
					@scene.remove highlight

		ns.stateMachine = (scene) ->
			return new StateMachine
				initial: "default"
				states:
					default:	new DefaultState scene
					move:		new MoveState scene
					selectAction:	new SelectActionState scene
					attack:		new AttackState scene

		return ns
