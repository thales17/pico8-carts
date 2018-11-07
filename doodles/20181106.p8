pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

maxSize = 10

Square = {
  x = 0,
  y = 0,  
  size = 1,
  sizeDir = 0.2,
  color = 10,
  frameDelay = 0,
}

function Square:new(o)
  self.__index = self
  return setmetatable(o or {}, self)
end

function Square:update()
  if (self.frameDelay > 0) then
    self.frameDelay -= 1
    return
  end

  self.size += self.sizeDir
  if (self.size < 1 or self.size > maxSize) then
    self.sizeDir *= -1
  end
end

function Square:draw()
  local halfMax = (maxSize / 2)
  local halfSize = (self.size / 2)
  local cx = halfMax + self.x
  local cy = halfMax + self.y

  rectfill(cx-halfSize,cy-halfSize,cx+halfSize,cy+halfSize,self.color)
  
end


function _init()
  squares = {}

  local grid = 128 / maxSize
  local delay = 0
  for i=0,(grid*grid) do
    local c = i % grid
    local r = flr(i / grid)
    local s = Square:new()
    s.frameDelay = delay
    s.x = c * maxSize
    s.y = r * maxSize
    add(squares, s)
    delay += 5
  end
end

function _update60()
  for s in all(squares) do
    s:update()
  end
end

function _draw()
  cls()
  for s in all(squares) do
    s:draw()
  end
end