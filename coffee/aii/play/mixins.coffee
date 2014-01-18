define ["jinn/mixins"],
	(mixins) ->
		ns = {}

		mixins.define
			healthHaver: ({hp, maxHp}) ->
				defaults:
					hp:	hp or maxHp
					maxHp:	maxHp

		return ns
