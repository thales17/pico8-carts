pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- written by Adam Richardson

Hexagon = {
  x = 0,
  y = 0,
  r = 10,
  rMax = 80,
  rDir = 1,
  delayFrames = 0,
  updateFrames = 1,
  frame = 0
}

function Hexagon:new(o)
  self.__index = self
  return setmetatable(o or {}, self)
end

function Hexagon:draw()
  local x = self.x
  local y = self.y
  local r = self.r
  local v1 = 0.866
  local v2 = 0.5
  
  line(
    r + x,
    y,
    (r * v2) + x,
    (r * v1) + y,
    15
  )
  line(
    (r * v2) + x,
    (r * v1) + y,
    (r * v2 * -1) + x,
    (r * v1) + y,
    14
  )
  line( 
    (r * v2 * -1) + x,
    (r * v1) + y,
    (r * -1) + x,
    y,
    13
  )
  line(
    (r * -1) + x,
    y,
    (r * v2 * -1) + x,
    (r * v1 * -1) + y,
    12
  )
  line(
    (r * v2 * -1) + x,
    (r * v1 * -1) + y,
    (r * v2) + x,
    (r * v1 * -1) + y,
    11
  )
  line(
    (r * v2) + x,
    (r * v1 * -1) + y,
    r + x,
    y,
    10
  )
end

function Hexagon:update()
  if (self.delayFrames > 0) then
    self.delayFrames -= 1
    return
  end

  self.frame += 1
  if (self.frame >= self.updateFrames) then
    self.r += self.rDir
    if (self.r >= self.rMax or self.r <= 0 ) then
      self.rDir *= -1
    end
  end

end

function _init()
  hexagons = {}
  for i=0,100 do
    local h = Hexagon:new()
    h.x = 64
    h.y = 64
    h.r = 1
    h.rMax = 80
    h.delayFrames = i * 20
    add(hexagons, h)
  end
end

function _update60()
  for h in all(hexagons) do
    h:update()
  end
end

function _draw()
  cls()
  for h in all(hexagons) do
    h:draw()
  end
end