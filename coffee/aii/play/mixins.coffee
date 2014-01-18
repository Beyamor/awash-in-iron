define ["jinn/mixins"],
	(mixins) ->
		ns = {}

		mixins.define
			healthHaver: ->
				maxHp: 10

				init: ->
					@hp or= @maxHp

				die: ->
					@remove()

			attacker: ->
				strength: 10

				attack: (other) ->
					other.hit @strength

			mover: ->
				speed: 10

			defender: ->
				hit: (damage) ->
					@hp -= damage
					@die() if @hp <= 0

		return ns
