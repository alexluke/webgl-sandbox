Matrix.Translation = (v) ->
    if v.elements.length == 2
        r = Matrix.I 3
        r.elements[2][0] = v.elements[0]
        r.elements[2][1] = v.elements[1]
        return r
    if v.elements.length == 3
        r = Matrix.I 4
        r.elements[0][3] = v.elements[0]
        r.elements[1][3] = v.elements[1]
        r.elements[2][3] = v.elements[2]
        return r
    throw "Invalid length for Translation"

Matrix.prototype.flatten = ->
    if @elements.length == 0
        return []

    results = []
    for j in [0...@elements[0].length]
        for i in [0...@elements.length]
            results.push this.elements[i][j]
    return results

Matrix.prototype.ensure4x4 = ->
    if @elements.length == 4 and @elements[0].length == 4
        return this

    if @elements.length > 4 or @elements[0].length > 4
        return null

    for i in [0...@elements.length]
        for j in [@elements[i].length...4]
            if i == j
                @elements[i].push 1
            else
                @elements[i].push 0

    for i in [@elements.length...4]
        if i == 0
            @elements.push [1, 0, 0, 0]
        else if i == 1
            @elements.push [0, 1, 0, 0]
        else if i == 2
            @elements.push [0, 0, 1, 0]
        else if i == 3
            @elements.push [0, 0, 0, 1]

    return this

Matrix.prototype.make3x3 = ->
    if @elements.length != 4 or @elements[0].length != 4
        return null

    Matrix.create [
        [@elements[0][0], @elements[0][1], @elements[0][2]]
        [@elements[1][0], @elements[1][1], @elements[1][2]]
        [@elements[2][0], @elements[2][1], @elements[2][2]]
    ]

