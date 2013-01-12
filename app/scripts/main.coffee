requirejs.config
    shim:
        sylvester:
            exports: 'Sylvester'
        'matrix.extensions': 'sylvester'
    paths:
        sylvester: 'vendor/sylvester'

require [
    'WebGL'
], (WebGL) ->
    canvas = document.getElementById('glcanvas')

    try
        gl = new WebGL canvas
    catch e
        alert e
        return

    requestAnimationFrame = window.requestAnimationFrame or
        window.webkitRequestAnimationFrame or
        window.mozRequestAnimationFrame or
        window.oRequestAnimationFrame or
        window.msRequestAnimationFrame or
        (callback) ->
            window.setTimeout callback, 1000 / 60

    draw = ->
        gl.draw()
        requestAnimationFrame draw
    draw()

