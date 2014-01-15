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
				@cancelEl = $(app.templates.compile "click-off-panel")
				app.container.append @cancelEl
				@cancelEl.click => @scene.controlState.switchTo "default"

				@menuEl = $(app.templates.compile "action-select-menu")
				app.container.append @menuEl
				@menuEl.offset
					left:	@scene.selectedUnit.tile.left
					top:	@scene.selectedUnit.tile.top

				$('.move', @menuEl).click => @scene.controlState.switchTo "move"
				$('.attack', @menuEl).click => @scene.controlState.switchTo "attack"
				$('.cancel', @menuEl).click => @scene.controlState.switchTo "default"

			update: ->
				if input.pressed "mouse-right"
					@scene.controlState.switchTo "default"

			end: ->
				@cancelEl.remove()
				@menuEl.remove()

		class MoveState extends ControlState
			begin: ->
				@highlights	= []
				@reachableTiles	= levels.tilesAround @scene.selectedUnit.tile, 3, (tile) ->
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
				@hittableTiles	= levels.tilesAround @scene.selectedUnit.tile, 5

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
