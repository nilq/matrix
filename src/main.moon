import * from require "brain"

export world = {
    width:  800
    height: 600
}

random_agent = ->
    a = {
        x: math.random 0, world.width
        y: math.random 0, world.height
        c: {
            r: math.random 0, 255
            g: math.random 0, 255
            b: math.random 0, 255
        }
        brain: Brain!
        r: 10 + math.random -4, 4
    }

    @out = {}
    for i = 1, OUTPUT_SIZE
        @out[i] = 0

    @inp  = {}
    for i = 1, INPUT_SIZE
        @inp[i] = 0

    a

reset = ->
    world.agents = {}
    world.foods  = {}

spawn_agents = (n) ->
    with world
        for i = 0, n
            .agents[#.agents + 1] = random_agent!

circles_intersect = (a, b) ->
    (a.r + b.r) / 2 > math.sqrt (a.x - b.x)^2 + (a.y - b.y)^2

with love
    .load = ->
        reset!
        spawn_agents 200
    
    .update = (dt) ->
        for agent in *world.agents
            continue unless agent
        
            agent.x += dt * math.random -100, 100
            agent.y += dt * math.random -100, 100

            ai = 0
            for agent2 in *world.agents
                continue unless agent2
                ai += 1
                if circles_intersect agent, agent2
                    if agent.r > agent2.r
                        agent.r += 1
                        table.remove world.agents, ai

    .draw = ->
        for agent in *world.agents
            .graphics.setColor agent.c.r, agent.c.g, agent.c.b
            .graphics.circle "fill", agent.x, agent.y, agent.r
            
            .graphics.setColor 255, 255, 255
            .graphics.circle "line", agent.x, agent.y, agent.r