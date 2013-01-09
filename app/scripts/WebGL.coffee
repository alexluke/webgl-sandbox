define ->
	class WebGL
		constructor: (canvas) ->
			if typeof canvas == 'string'
				canvas = document.getElementById(canvas)
			@gl = null

			try
				@gl = canvas.getContext('webgl') or canvas.getContext('experimental-webgl')
			catch e

			if not @gl
				throw 'Cannot init WebGL'

