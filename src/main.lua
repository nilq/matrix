world = {
  width = 800,
  height = 600
}
local random_agent
random_agent = function()
  return {
    x = math.random(0, world.width),
    y = math.random(0, world.height),
    c = {
      r = math.random(0, 255),
      g = math.random(0, 255),
      b = math.random(0, 255)
    },
    r = 10 + math.random(-4, 4)
  }
end
local reset
reset = function()
  world.agents = { }
  world.foods = { }
end
local spawn_agents
spawn_agents = function(n)
  do
    for i = 0, n do
      world.agents[#world.agents + 1] = random_agent()
    end
    return world
  end
end
local circles_intersect
circles_intersect = function(a, b)
  return (a.r + b.r) / 2 > math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)
end
do
  local _with_0 = love
  _with_0.load = function()
    reset()
    return spawn_agents(200)
  end
  _with_0.update = function(dt)
    local _list_0 = world.agents
    for _index_0 = 1, #_list_0 do
      local _continue_0 = false
      repeat
        local agent = _list_0[_index_0]
        if not (agent) then
          _continue_0 = true
          break
        end
        agent.x = agent.x + (dt * math.random(-100, 100))
        agent.y = agent.y + (dt * math.random(-100, 100))
        local ai = 0
        local _list_1 = world.agents
        for _index_1 = 1, #_list_1 do
          local _continue_1 = false
          repeat
            local agent2 = _list_1[_index_1]
            if not (agent2) then
              _continue_1 = true
              break
            end
            ai = ai + 1
            if circles_intersect(agent, agent2) then
              if agent.r > agent2.r then
                agent.r = agent.r + 1
                table.remove(world.agents, ai)
              end
            end
            _continue_1 = true
          until true
          if not _continue_1 then
            break
          end
        end
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end
  _with_0.draw = function()
    local _list_0 = world.agents
    for _index_0 = 1, #_list_0 do
      local agent = _list_0[_index_0]
      _with_0.graphics.setColor(agent.c.r, agent.c.g, agent.c.b)
      _with_0.graphics.circle("fill", agent.x, agent.y, agent.r)
      _with_0.graphics.setColor(255, 255, 255)
      _with_0.graphics.circle("line", agent.x, agent.y, agent.r)
    end
  end
  return _with_0
end
