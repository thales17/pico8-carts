pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- written by Adam Richardson

Particle = {
  x = 0,
  y = 0,
  xDir = 0,
  yDir = 0,
  color = 11
}

function Particle:new(o)
  self.__index = self
  return setmetatable(o or {}, self)
end

function Particle:update()
  self.x += self.xDir
  self.y += self.yDir
end

function Particle:draw()
  pset(self.x,self.y,self.color)
end

Emitter = {
  maxParticles = 100,
  count = 0,
  particles = {}
}

function Emitter:new(o)
  self.__index = self
  return setmetatable(o or {}, self)
end

function Emitter:update()
  for p in all(self.particles) do
    p:update()
  end
end

function Emitter:draw()
  for p in all(self.particles) do
    p:draw()
  end
end

function Emitter:emit(x, y)
  local p = Particle:new()
  p.x = x
  p.y = y
  local dice = rnd(10)
  p.xDir = 2 + ceil(rnd(2)) 
  if (dice > 5) then
    p.xDir *= -1
  end
  dice = rnd(10)
  p.yDir = 2 + ceil(rnd(2))
  if (dice > 5) then
    p.yDir *= -1
  end

  p.color = 1 + ceil(rnd(14))

  if (self.count < self.maxParticles) then
    add(self.particles, p)
  else
    del(self.particles, 1)
    add(self.particles, p)
  end
end

Firework = {
  x = 0,
  y = 128,
  speed = 2,
  destY = 10,
  pop = false
}

function Firework:new(o)
  self.__index = self
  return setmetatable(o or {}, self)
end

function Firework:update()
  if (self.y == self.destY) then
    return
  end

  self.y -= self.speed
  if (self.y <= self.destY) then
    self.pop = true
    self.y = self.destY
  end
end

function Firework:draw()
  pset(self.x, self.y, 7)
end

function _init()
  emitter = Emitter:new()
  fireworks = {}
  for i = 0,2 do
    local f = Firework:new()
    f.x = flr(rnd(128))
    f.speed = 1 + flr(rnd(2))
    f.destY = 50 + ceil(rnd(45))
    add(fireworks, f)
  end
end

function _update60()
  index = 0
  for f in all(fireworks) do
    f:update()
    if (f.pop) then
      for i = 0,20 do
        emitter:emit(f.x, f.y)
      end
      f.pop = false
      f.y = 128
      f.x = flr(rnd(128))
      -- local f = Firework:new()
      -- f.x = flr(rnd(128))
      -- f.speed = 5 + ceil(rnd(10))
      -- f.destY = 25 + ceil(rnd(70))
      -- add(fireworks, f)
    end
    index += 1
  end
  emitter:update()
end

function _draw()
  cls()
  emitter:draw()
  for f in all(fireworks) do
    f:draw()
  end
end