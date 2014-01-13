define ['jinn/scenes'],
	({Scene}) ->
		ns = {}

		class ns.PlayScene extends Scene
			begin: ->
				super()
				console.log "beginning play scene"

		return ns
