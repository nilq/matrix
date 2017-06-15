local inp_size = 4
local out_size = 2
local conns = 3
local brain_size = 25
local return_v = false
local value_v = 0
local gauss_random
gauss_random = function()
  if return_v then
    return_v = false
    return value_v
  end
  local u = 2 * math.random() - 1
  local v = 2 * math.random() - 1
  local r = u ^ 2 + v ^ 2
  if r == 0 or r > 1 then
    return gauss_random()
  end
  local c = math.sqrt(-2 * (math.log(r)) / r)
  value_v = v * c
  return u * c
end
local randf
randf = function(a, b)
  return (b - a) * math.random() + a
end
local randi
randi = function(a, b)
  return math.floor((b - a) * math.random() + a)
end
local randn
randn = function(mu, sigma)
  return mu + gauss_random() * sigma
end
local Brain
do
  local _class_0
  local _base_0 = {
    tick = function(self, inp, out)
      for i = 1, inp_size do
        self.boxes[i].out = inp[i]
      end
      for i = inp_size, brain_size do
        local a = self.boxes[i]
        if a.type == 0 then
          local res = 1
          for j = 1, conns do
            local idx = a.id[j]
            local val = self.boxes[idx].out
            if a.notted[j] then
              val = 1 - val
            end
            res = res * val
          end
          res = res * a.bias
          a.target = res
        else
          local res = 0
          for j = 1, conns do
            local idx = a.id[j]
            local val = self.boxes[idx].out
            if a.notted[j] then
              val = 1 - val
            end
            res = res + (val * a.w[j])
          end
          res = res + a.bias
          a.target = res
        end
        if a.target < 0 then
          a.target = 0
        elseif a.target > 1 then
          a.target = 1
        end
      end
      for i = inp_size, brain_size do
        local a = self.boxes[i]
        a.out = a.out + ((a.target - a.out) * a.kp)
      end
      for i = 1, out_size do
        out[i] = self.boxes[brain_size - i].out
      end
    end,
    mutate = function(self, mr, mr2)
      for i = 1, brain_size do
        if mr * 3 > randf(0, 1) then
          self.boxes[i].bias = self.boxes[i].bias + randn(0, mr2)
        end
        if mr * 3 > util.randf(0, 1) then
          local rc = randi(1, CONNS)
          self.boxes[i].w[rc] = self.boxes[i].w[rc] + randn(0, mr2)
          if self.boxes[i].w[rc] > 0.01 then
            self.boxes[i].w[rc] = 0.01
          end
        end
        if mr > util.randf(0, 1) then
          local rc = randi(1, CONNS)
          local ri = randi(1, BRAIN_SIZE)
          self.boxes[i].id[rc] = ri
        end
        if mr > randf(0, 1) then
          local rc = randi(1, CONNS)
          self.boxes[i].notted[rc] = not self.boxes[i].notted[rc]
        end
        if mr > randf(0, 1) then
          self.boxes[i].type = 1 - self.boxes[i].type
        end
      end
    end,
    crossover = function(self, other)
      local new_brain = Brain:from_brain(self)
      for i = 1, #new_brain.boxes do
        new_brain.boxes[i].bias = other.boxes[i].bias
        new_brain.boxes[i].kp = other.boxes[i].kp
        new_brain.boxes[i].type = other.boxes[i].type
        if 0.5 > randf(0, 1) then
          new_brain.boxes[i].bias = self.boxes[i].bias
        end
        if 0.5 > randf(0, 1) then
          new_brain.boxes[i].kp = self.boxes[i].kp
        end
        if 0.5 > randf(0, 1) then
          new_brain.boxes[i].type = self.boxes[i].type
        end
        for j = 1, #new_brain.boxes[i].id do
          new_brain.boxes[i].id[j] = other.boxes[i].id[j]
          new_brain.boxes[i].notted[j] = other.boxes[i].notted[j]
          new_brain.boxes[i].w[j] = other.boxes[i].w[j]
          if 0.5 > randf(0, 1) then
            new_brain.boxes[i].id[j] = self.boxes[i].id[j]
          end
          if 0.5 > randf(0, 1) then
            new_brain.boxes[i].notted[j] = self.boxes[i].notted[j]
          end
          if 0.5 > randf(0, 1) then
            new_brain.boxes[i].w[j] = self.boxes[i].w[j]
          end
        end
      end
      return new_brain
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.boxes = { }
      for i = 1, brain_size do
        local a = Box()
        self.boxes[#self.boxes + 1] = a
        for j = 1, conns do
          if 0.05 > randf(0, 1) then
            a.id[j] = 1
          end
          if 0.05 > randf(0, 1) then
            a.id[j] = 5
          end
          if 0.05 > randf(0, 1) then
            a.id[j] = 12
          end
          if 0.05 > randf(0, 1) then
            a.id[j] = 4
          end
          if i < brain_size / 2 then
            a.id[j] = randi(1, inp_size)
          end
        end
      end
    end,
    __base = _base_0,
    __name = "Brain"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.from_brain = function(self, other)
    local brain = DWRAONBrain()
    brain.boxes = table.deepcopy(other.boxes)
    return brain
  end
  Brain = _class_0
end
local Box
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.type = 0
      if 0.5 > randf(0, 1) then
        self.type = 1
      end
      self.kp = randf(0.8, 1)
      self.w = { }
      self.id = { }
      self.notted = { }
      for i = 1, conns do
        self.w[i] = randf(0.1, 2)
        self.id[i] = randi(1, brain_size)
        if 0.2 > randf(0, 1) then
          self.id[i] = randi(1, inp_size)
        end
        self.notted[i] = 0.5 > randf(0, 1)
      end
      self.bias = randf(-1, 1)
      self.target = 0
      self.out = 0
    end,
    __base = _base_0,
    __name = "Box"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Box = _class_0
  return _class_0
end
