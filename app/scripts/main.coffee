require [
], ->
	canvas = document.getElementById('glcanvas')
	gl = null

	#try
	gl = canvas.getContext('webgl') or canvas.getContext('experimental-webgl')
	#catch e

	if not gl
		alert 'Cannot init WebGL'
		return

	gl.clearColor 0.0, 0.0, 0.0, 1.0
	gl.enable gl.DEPTH_TEST
	gl.depthFunc gl.LEQUAL
	gl.clear gl.COLOR_BUFFER_BIT|gl.DEPTH_BUFFER_BIT

