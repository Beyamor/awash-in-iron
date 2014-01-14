define ["jinn/control/states", "jinn/input"],
	({StateMachine}, input) ->
		ns = {}

		class DefaultState
			constructor: (@level) ->

			update: ->
				if input.pressed "mouse-left"
					if @level.mouseTile.unit?
						@level.selectedUnit = @level.mouseTile.unit
						@level.controlState.switchTo "selected"

		class SelectedState
			showsHiglight: true

			constructor: (@level) ->

			update: ->
				if input.pressed "mouse-left"
					unless @level.mouseTile.unit?
						@level.mouseTile.addUnit @level.selectedUnit
						@level.controlState.switchTo "default"

				if input.pressed "mouse-right"
					@level.controlState.switchTo "default"

		ns.stateMachine = (level) ->
			return new StateMachine
				initial: "default"
				states:
					default:	new DefaultState level
					selected:	new SelectedState level

		return ns
