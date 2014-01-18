define ["jinn/mixins"],
	(mixins) ->
		ns = {}

		mixins.define
			healthHaver: ->
				init: ->
					@hp or= @maxHp

				die: ->
					@remove()

			attacker: ->
				attack: (other) ->
					other.hit @strength

			defender: ->
				hit: (damage) ->
					@hp -= damage
					@die() if @hp <= 0

		return ns
