define [
	'sylvester'
] (Matrix, Vector) ->
	class WebGL
		constructor: (canvas) ->
			if typeof canvas == 'string'
				canvas = document.getElementById(canvas)
			@gl = null

			try
				@gl = canvas.getContext('webgl') or canvas.getContext('experimental-webgl')
			catch e

			if not @gl
				return null

			@width = canvas.width
			@height = canvas.height
			@horizAspect = @height / @width

		initShaders: ->
			fragment = @_getShader 'shader-fs'
			vertex = @_getShader 'shader-vs'

			shaderProgram = @gl.createProgram()
			@gl.attachShader shaderProgram, vertex
			@gl.attachShader shaderProgram, fragment
			@gl.linkProgram shaderProgram

			if not @gl.getProgramParameter shaderProgram, @gl.LINK_STATUS
				return null

			@gl.useProgram shaderProgram

			@vertextPositionAttribute = @gl.getAttribLocation shaderProgram, 'aVertexPosition'
			@gl.enableVertexAttribArray vertextPositionAttribute

		_getShader: (id) ->
			shaderScript = document.getElementById id
			if not shaderScript
				return null

			switch shaderScript.type
				when 'x-shader/x-fragment' then
					shader = @gl.createShader @gl.FRAGMENT_SHADER
				when 'x-shader/x-vertex' then
					shader = @gl.createShader @gl.VERTEX_SHADER
				else
					return null

			source = ''
			currentChild = shaderScript.firstChild

			while currentChild
				if currentChild.nodeType == currentChild.TEXT_NODE
					source += currentChild.textContent
				currentChild = currentChild.nextSibling

			@gl.shaderSource shader, source
			@gl.compileShader shader

			if @gl.getShaderParameter shader, @gl.COMPILE_STATUS
				throw "Cannot compile shader #{ id }"

			return shader

		initBuffers: ->
			@squareVerticesBuffer = @gl.createBuffer()
			@gl.bindBuffer @gl.ARRAY_BUFFER, squareVerticesBuffer

			vertices = [
				1.0, 1.0, 0.0
				-1.0, 1.0, 0.0
				1.0, -1.0, 0.0
				-1.0, -1.0, 0.0
			]

			@gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW

		draw: ->
			@gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT

			@perspectiveMatrix = makePerspective 45, @width/@height, 0.1, 100.0
			loadIdentity()
			mvTranslate [-0.0, 0.0, -6.0]
			@gl.bindBuffer @gl.ARRAY_BUFFER, @squareVerticesBuffer
			@gl.vertexAttribPointer vertextPositionAttribute, 3, @gl.FLOAT, false, 0, 0
			@setMatrixUniforns()
			@gl.drawArarys @gl.TRIANGLE_STRIP, 0, 4


		loadIdentity: ->
			@mvMatrix = Matrix.I 4

		multMatrix: (m) ->
			@mvMatrix = mvMatrix.x m

		mvTranslate: (v) ->
			@multMatrix Matrix.Translation Vector.create(v[0], v[1], v[2]).ensure4x4()

		setMatrixUniforms: ->
			pUniform = @gl.getUniformLocation @shaderProgram, 'uPMatrix'
			@gl.uniformMatrix4fv pUniform, false, new Float32Array @perspectiveMatrix.flatten()

			mvUniform = @gl.getUniformLocation @shaderProgram, 'uMVMatrix'
			@gl.uniformMatrix4fv mvUniform, false, new Float32Array @mvMatrix.flatten()
