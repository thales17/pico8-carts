pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

Pixel = {
  x = 0,
  y = 0,
  v = 1
}

function Pixel:new(o)
  self.__index = self
  return setmetatable(o or {}, self)
end

Gridlet = {
  x = 0,
  y = 0,
  pixelData = {},
  rotatedPixelData = {},
  angle = 0,
  color = 7,
  size = 10
}

function Gridlet:new(o)
  self.__index = self
  return setmetatable(o or {}, self)
end

function Gridlet:init()
  local half =  ceil(self.size / 2)
  for i = 0,self.size do
    for j = 0,self.size do
      local p = Pixel:new()
      p.x = j - half
      p.y = i - half
      p.v = (i+j)%2
      add(self.pixelData, p)
    end
  end
end

function Gridlet:draw()
  for p in all(self.rotatedPixelData) do
    if (p.v == 1) then
      pset(self.x+p.x,self.y+p.y,self.color)
    end
  end
end

function Gridlet:applyRotation()
  self.rotatedPixelData = {}
  for p in all(self.pixelData) do
    pPrime = Pixel:new()
    pPrime.x = p.x * cos(self.angle) - p.y * sin(self.angle)
    pPrime.y = p.x * sin(self.angle) - p.y * cos(self.angle)
    add(self.rotatedPixelData, pPrime)
  end
end

function Gridlet:update()
  self.angle += 0.01
  if (self.angle > 1) then
    self.angle = 0
  end
  self:applyRotation()
end

function _init()
  gridlets = {}
  for i = 0,1 do
    local g = Gridlet:new()
    g.x = 64
    g.y = 64
    g.size = 10
    g.color = 10
    g:init()
    add(gridlets, g)
  end
end

function _update60()
  for g in all(gridlets) do
    g:update()
  end
end

function _draw()
  cls(8)
  for g in all(gridlets) do
    g:draw()
  end
end