define ['jinn/scenes', "aii/play/levels"],
	({Scene}, {Level}) ->
		ns = {}

		class ns.PlayScene extends Scene
			begin: ->
				super()

				@level = new Level
				@add tile for tile in @level.tiles

		return ns
