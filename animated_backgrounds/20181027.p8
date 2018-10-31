pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- written by Adam Richardson

Plus = {
  x = 0,
  y = 0,
  color = 7,
  spacing = 0,
  spacingMax = 50,
  spacingDir = 1,
  size = 10,
  updateFrames = 2,
  frame = 0
}

function Plus:new(o) 
  self.__index = self
  return setmetatable(o or {}, self)
end

function Plus:draw()
  local x = self.x
  local y = self.y
  local color = self.color
  local spacing = self.spacing
  local size = self.size
  -- top
  line(x,y-spacing,x,y-spacing-size,color)
  -- bottom
  line(x,y+spacing,x,y+spacing+size,color)
  -- left
  line(x-spacing,y,x-spacing-size,y,color)
  -- right
  line(x+spacing,y,x+spacing+size,y,color)
end

function Plus:update()
  self.frame += 1
  if (self.frame >= self.updateFrames) then
    self.frame = 0
    self.spacing += self.spacingDir
    if (self.spacing >= self.spacingMax or self.spacing <= 0) then
      self.spacingDir *= -1
    end
  end
end

function _init()
  pluses = {}
  for i=0,50 do
    local plus = Plus:new()
    plus.x = ceil(rnd(128))
    plus.y = ceil(rnd(128))
    plus.color = ceil(rnd(16))
    plus.updateFrames = ceil(rnd(5))
    plus.size = 3 + ceil(rnd(7))
    plus.spacingMax = 10 + ceil(rnd(40))
    add(pluses, plus)
  end
end

function _update60()
  for p in all(pluses) do
    p:update()
  end
end

function _draw()
  cls()
  for p in all(pluses) do
    p:draw()
  end
end