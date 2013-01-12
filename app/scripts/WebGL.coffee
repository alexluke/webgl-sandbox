define [
    'sylvester'
    'matrix.extensions'
], (Sylvester, extension) ->
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

            @width = canvas.width
            @height = canvas.height
            @horizAspect = @height / @width

            @gl.clearColor 0.0, 0.0, 0.0, 1.0
            @gl.clearDepth 1.0
            @gl.enable @gl.DEPTH_TEST
            @gl.depthFunc @gl.LEQUAL

            @initShaders()
            @initBuffers()

        initShaders: ->
            fragment = @_getShader 'shader-fs'
            vertex = @_getShader 'shader-vs'

            @shaderProgram = @gl.createProgram()
            @gl.attachShader @shaderProgram, vertex
            @gl.attachShader @shaderProgram, fragment
            @gl.linkProgram @shaderProgram

            if not @gl.getProgramParameter @shaderProgram, @gl.LINK_STATUS
                return null

            @gl.useProgram @shaderProgram

            @vertexPositionAttribute = @gl.getAttribLocation @shaderProgram, 'aVertexPosition'
            @gl.enableVertexAttribArray @vertexPositionAttribute

            @vertexColorAttribute = @gl.getAttribLocation @shaderProgram, 'aVertexColor'
            @gl.enableVertexAttribArray @vertexColorAttribute

        _getShader: (id) ->
            shaderScript = document.getElementById id
            if not shaderScript
                return null

            switch shaderScript.type
                when 'x-shader/x-fragment'
                    shader = @gl.createShader @gl.FRAGMENT_SHADER
                when 'x-shader/x-vertex'
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

            if not @gl.getShaderParameter shader, @gl.COMPILE_STATUS
                throw "Cannot compile shader #{ id }"

            return shader

        initBuffers: ->
            @squareVerticesBuffer = @gl.createBuffer()
            @gl.bindBuffer @gl.ARRAY_BUFFER, @squareVerticesBuffer

            vertices = [
                1.0, 1.0, 0.0
                -1.0, 1.0, 0.0
                1.0, -1.0, 0.0
                -1.0, -1.0, 0.0
            ]

            @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW

            @squareVerticesColorBuffer = @gl.createBuffer()
            @gl.bindBuffer @gl.ARRAY_BUFFER, @squareVerticesColorBuffer

            colors = [
                1.0, 1.0, 1.0, 1.0 # white
                1.0, 0.0, 0.0, 1.0 # red
                0.0, 1.0, 0.0, 1.0 # green
                0.0, 0.0, 1.0, 1.0 # blue
            ]

            @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(colors), @gl.STATIC_DRAW

        draw: ->
            @gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT

            @perspectiveMatrix = @makePerspective 45, @width/@height, 0.1, 100.0

            @loadIdentity()
            @mvTranslate [-0.0, 0.0, -6.0]

            @gl.bindBuffer @gl.ARRAY_BUFFER, @squareVerticesBuffer
            @gl.vertexAttribPointer @vertexPositionAttribute, 3, @gl.FLOAT, false, 0, 0
            @gl.bindBuffer @gl.ARRAY_BUFFER, @squareVerticesColorBuffer
            @gl.vertexAttribPointer @vertexColorAttribute, 4, @gl.FLOAT, false, 0, 0
            @setMatrixUniforms()
            @gl.drawArrays @gl.TRIANGLE_STRIP, 0, 4

        loadIdentity: ->
            @mvMatrix = Matrix.I 4

        multMatrix: (m) ->
            @mvMatrix = @mvMatrix.x m

        mvTranslate: (v) ->
            @multMatrix Matrix.Translation(Vector.create([v[0], v[1], v[2]])).ensure4x4()

        setMatrixUniforms: ->
            pUniform = @gl.getUniformLocation @shaderProgram, 'uPMatrix'
            @gl.uniformMatrix4fv pUniform, false, new Float32Array @perspectiveMatrix.flatten()

            mvUniform = @gl.getUniformLocation @shaderProgram, 'uMVMatrix'
            @gl.uniformMatrix4fv mvUniform, false, new Float32Array @mvMatrix.flatten()

        makePerspective: (fovy, aspect, znear, zfar) ->
            ymax = znear * Math.tan(fovy * Math.PI / 360.0)
            ymin = -ymax
            xmin = ymin * aspect
            xmax = ymax * aspect

            @makeFrustrum xmin, xmax, ymin, ymax, znear, zfar

        makeFrustrum: (left, right, bottom, top, znear, zfar) ->
            x = 2 * znear / (right - left)
            y = 2 * znear / (top - bottom)
            a = (right + left) / (right - left)
            b = (top + bottom) / (top - bottom)
            c = -(zfar + znear) / (zfar - znear)
            d = -2 * zfar * znear / (zfar - znear)

            Matrix.create [
                [x, 0, a, 0]
                [0, y, b, 0]
                [0, 0, c, d]
                [0, 0, -1, 0]
            ]

