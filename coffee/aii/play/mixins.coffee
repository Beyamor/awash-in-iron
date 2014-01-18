define ["jinn/mixins"],
	(mixins) ->
		ns = {}

		mixins.define
			healthHaver: ({hp, maxHp}) ->
				defaults:
					hp:	hp or maxHp
					maxHp:	maxHp

			attacker: ({strength}) ->
				defaults:
					strength:	strength
					attack: (other) ->

			mover: ({speed}) ->
				defaults:
					speed:		speed


		return ns
