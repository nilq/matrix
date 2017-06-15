inp_size = 4
out_size = 2
conns = 3
brain_size = 25

return_v = false
value_v  = 0

gauss_random = ->
    if return_v
        return_v = false
        return value_v

    u = 2 * math.random! - 1
    v = 2 * math.random! - 1

    r = u^2 + v^2

    if r == 0 or r > 1
        return gauss_random!

    c = math.sqrt -2 * (math.log r) / r
    value_v = v * c

    u * c

randf = (a, b) ->
    (b - a) * math.random! + a

randi = (a, b) ->
    math.floor (b - a) * math.random! + a

randn = (mu, sigma) ->
    mu + gauss_random! * sigma

class Brain
    new: =>
        @boxes = {}

        for i = 1, brain_size
            a = Box!

            @boxes[#@boxes + 1] = a

            for j = 1, conns
                if 0.05 > randf 0, 1
                    a.id[j] = 1
                if 0.05 > randf 0, 1
                    a.id[j] = 5
                if 0.05 > randf 0, 1
                    a.id[j] = 12
                if 0.05 > randf 0, 1
                    a.id[j] = 4

                if i < brain_size / 2
                    a.id[j] = randi 1, inp_size

    @from_brain: (other) =>
        brain = DWRAONBrain!
        brain.boxes = table.deepcopy other.boxes
        brain

    tick: (inp, out) =>
        for i = 1, inp_size
            @boxes[i].out = inp[i]

        for i = inp_size, brain_size
            a = @boxes[i]

            if a.type == 0 -- and
                res = 1

                for j = 1, conns
                    idx = a.id[j]
                    val = @boxes[idx].out

                    if a.notted[j]
                        val = 1 - val

                    res *= val

                res *= a.bias
                a.target = res

            else -- or
                res = 0

                for j = 1, conns
                    idx = a.id[j]
                    val = @boxes[idx].out

                    if a.notted[j]
                        val = 1 - val

                    res += val * a.w[j]

                res += a.bias
                a.target = res

            -- sigmoid plz?
            if a.target < 0
                a.target = 0
            elseif a.target > 1
                a.target = 1

        for i = inp_size, brain_size
            a = @boxes[i]
            a.out += (a.target - a.out) * a.kp

        for i = 1, out_size
            out[i] = @boxes[brain_size - i].out

    mutate: (mr, mr2) =>
        for i = 1, brain_size

            if mr * 3 > randf 0, 1
                @boxes[i].bias += randn 0, mr2

            if mr * 3 > util.randf 0, 1
                rc = randi 1, CONNS

                @boxes[i].w[rc] += randn 0, mr2
                if @boxes[i].w[rc] > 0.01
                    @boxes[i].w[rc] = 0.01

            if mr > util.randf 0, 1
                rc = randi 1, CONNS
                ri = randi 1, BRAIN_SIZE

                @boxes[i].id[rc] = ri

            if mr > randf 0, 1
                rc = randi 1, CONNS

                @boxes[i].notted[rc] = not @boxes[i].notted[rc]

            if mr > randf 0, 1
                @boxes[i].type = 1 - @boxes[i].type

    crossover: (other) =>
        new_brain = Brain\from_brain @

        for i = 1, #new_brain.boxes

            new_brain.boxes[i].bias = other.boxes[i].bias
            new_brain.boxes[i].kp   = other.boxes[i].kp
            new_brain.boxes[i].type = other.boxes[i].type

            if 0.5 > randf 0, 1
                new_brain.boxes[i].bias = @boxes[i].bias
            if 0.5 > randf 0, 1
                new_brain.boxes[i].kp = @boxes[i].kp
            if 0.5 > randf 0, 1
                new_brain.boxes[i].type = @boxes[i].type

            for j = 1, #new_brain.boxes[i].id

                new_brain.boxes[i].id[j] = other.boxes[i].id[j]
                new_brain.boxes[i].notted[j] = other.boxes[i].notted[j]
                new_brain.boxes[i].w[j] = other.boxes[i].w[j]

                if 0.5 > randf 0, 1
                    new_brain.boxes[i].id[j] = @boxes[i].id[j]
                if 0.5 > randf 0, 1
                    new_brain.boxes[i].notted[j] = @boxes[i].notted[j]
                if 0.5 > randf 0, 1
                    new_brain.boxes[i].w[j] = @boxes[i].w[j]

        new_brain

class Box
    new: =>
        @type = 0
        if 0.5 > randf 0, 1
            @type = 1

        @kp = randf 0.8, 1

        @w      = {}
        @id     = {}
        @notted = {}

        for i = 1, conns
            @w[i]  = randf 0.1, 2
            @id[i] = randi 1, brain_size

            if 0.2 > randf 0, 1
                @id[i] = randi 1, inp_size

            @notted[i] = 0.5 > randf 0, 1

        @bias = randf -1, 1

        @target = 0
        @out = 0
