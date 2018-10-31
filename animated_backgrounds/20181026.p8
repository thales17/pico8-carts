pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- written by Adam Richardson

Square = {
  x = 0,
  y = 0,
  size = 12,
  inset = 3,
  hightlightPos = 1,
  lineColor = 7,
  highlightColor = 11,
  updateFrames = 10,
  frame = 0
}

function Square:new(o)
  self.__index = self
  return setmetatable(o or {}, self)
end

function Square:draw()
  local x = self.x
  local y = self.y
  local size = self.size
  local inset = self.inset
  local hightlightPos = self.hightlightPos
  local lineColor = self.lineColor
  local highlightColor = self.highlightColor
  local colors = {lineColor, lineColor, lineColor, lineColor}
  colors[hightlightPos] = highlightColor
  line(x+inset,y,x+size-inset,y,colors[1])
  line(x+size,y+inset,x+size,y+size-inset,colors[2])
  line(x+size-inset,y+size,x+inset,y+size,colors[3])
  line(x,y+size-inset,x,y+inset,colors[4])
end

function Square:update()
  self.frame += 1
  if (self.frame >= self.updateFrames) then
    self.hightlightPos += 1
    if (self.hightlightPos == 5) then
      self.hightlightPos = 1
    end
    self.frame = 0
  end
end

function _init()
  squares = {}
  for i=0,800 do
    local s = Square:new()
    s.x = flr(rnd(110))
    s.y = flr(rnd(110))
    s.lineColor = ceil(rnd(15))
    s.highlightColor = ceil(rnd(15))
    s.updateFrames = 5 + ceil(rnd(10))
    add(squares, s)
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