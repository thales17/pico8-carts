pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

Spiral = {
  x = 0,
  y = 0,
  radius = 2,
  angle = 0,
  minR = 2,
  maxR = 64,
  color = 15,
  clearNeeded = true
}

function Spiral:new(o)
  self.__index = self
  return setmetatable(o or {}, self)
end

function Spiral:draw()
  local x = cos(self.angle) * self.radius + self.x
  local y = sin(self.angle) * self.radius + self.y
  pset(x, y, self.color)
end

function Spiral:update()
  self.angle += 0.02
  if (self.angle >= 1) then
    self.angle = 0
  end
  self.radius += 0.1
  if (self.radius >= self.maxR) then
    self.radius = self.minR
    self.clearNeeded = true
  end

  -- self.color += 1
  -- if self.color > 15 then
  --   self.color = 0
  -- end
end

function _init()
  spiral = Spiral:new()
  spiral.x = 64
  spiral.y = 64
end

function _update60()
  spiral:update()
end

function _draw()
  if (spiral.clearNeeded) then
    spiral.clearNeeded = false
    cls(3)
  end

  spiral:draw()
end