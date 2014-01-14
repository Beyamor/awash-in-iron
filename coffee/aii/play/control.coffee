define ["jinn/control/states", "jinn/input"],
	({StateMachine}, input) ->
		ns = {}

		class ControlState
			constructor: (@scene) ->

			begin: ->
				if @showsHiglight
					@scene.tileHighlight.show()
				else
					@scene.tileHighlight.hide()

		class DefaultState extends ControlState
			update: ->
				if input.pressed "mouse-left"
					if @scene.mouseTile.unit?
						@scene.selectedUnit = @scene.mouseTile.unit
						@scene.controlState.switchTo "selected"

		class SelectedState extends ControlState
			showsHiglight: true

			update: ->
				if input.pressed "mouse-left"
					unless @scene.mouseTile.unit?
						@scene.mouseTile.addUnit @scene.selectedUnit
						@scene.controlState.switchTo "default"

				if input.pressed "mouse-right"
					@scene.controlState.switchTo "default"

		ns.stateMachine = (scene) ->
			return new StateMachine
				initial: "default"
				states:
					default:	new DefaultState scene
					selected:	new SelectedState scene

		return ns
