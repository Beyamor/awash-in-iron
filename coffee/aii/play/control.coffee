define ["jinn/control/states", "jinn/input", "aii/play/levels"],
	({StateMachine}, input, levels) ->
		ns = {}

		class ControlState
			constructor: (@scene) ->

		class DefaultState extends ControlState
			update: ->
				if input.pressed "mouse-left"
					if @scene.mouseTile.unit?
						@scene.selectedUnit = @scene.mouseTile.unit
						@scene.controlState.switchTo "move"

		class MoveState extends ControlState
			begin: ->
				@reachableTiles	= levels.reachableTiles @scene.selectedUnit.tile, 3
				@highlights	= []

				for tile in @reachableTiles
					highlight = new levels.TileHighlight tile
					@scene.add highlight
					@highlights.push highlight

			update: ->
				if input.pressed "mouse-left"
					unless @scene.mouseTile.unit?
						@scene.mouseTile.addUnit @scene.selectedUnit
						@scene.controlState.switchTo "default"

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

		return ns
