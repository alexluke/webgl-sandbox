requirejs.config
	shim:
		'sylvester':
			exports: ['Matrix', 'Vector']

require [
	'WebGL'
], (WebGL) ->
	canvas = document.getElementById('glcanvas')

	gl = new WebGL canvas

	if not gl
		alert 'Cannot init WebGL'
		return

	gl.gl.clearColor 0.0, 0.0, 0.0, 1.0
	gl.gl.enable gl.gl.DEPTH_TEST
	gl.gl.depthFunc gl.gl.LEQUAL
	gl.gl.clear gl.gl.COLOR_BUFFER_BIT|gl.gl.DEPTH_BUFFER_BIT
