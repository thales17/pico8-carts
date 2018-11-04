pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- written by Adam Richardson

FallingPoint = {
  x = 0,
  y = 0,
  destY = 0,
  speed = 1,
  landed = false,
  isTypeA = true
}

function FallingPoint:new(o)
  self.__index = self
  return setmetatable(o or {}, self)
end

function FallingPoint:fall()
  if (self.landed) then
    return
  end

  if (self.y >= self.destY) then
    if (self.y > self.destY) then
      self.y = self.destY
    end
    self.landed = true
    return
  end

  self.y += self.speed
end

function drawBlockA(x, y, c)
  rectfill(x,y,x+blockSize,y+blockSize,c)
end

function drawBlockB(x, y, c)
  rectfill(x,y,x+blockSize,y+blockSize,c)
end

function _init()
  fallingPoints = {}
  fallenPoints = {}
  blockSize = 6
  currentRow = 20
  clearNeeded = true
end

function generateRowBlocks()
  fallingPoints = {}
  for i = 0,20 do
    local f = FallingPoint:new()
    f.x = i * blockSize
    f.y = (i * -(i / 2)) * blockSize
    f.destY = currentRow * blockSize
    f.speed = 5 + flr(i / 2)
    local r = rnd(10)
    if (r > 5) then
      f.isTypeA = false
    end
    add(fallingPoints, f)
  end
end

function _update60()
  allFall = true
  for fp in all(fallingPoints) do
    if (not fp.landed) then
      fp:fall()
      allFall = false
    end
  end

  if (allFall) then
    currentRow -= 1
    for fp in all(fallingPoints) do
      add(fallenPoints, fp)
    end
    if (currentRow < 0) then
      currentRow = 20
      fallenPoints = {}
    end
    generateRowBlocks()
  end
end

function _draw()
  cls()
  for fp in all(fallingPoints) do
    local y = fp.y
    if (y > fp.destY) then
      y = fp.destY
    end
    if (fp.isTypeA) then
      drawBlockA(fp.x, y, 7)
    else
      drawBlockA(fp.x, y, 8)
    end
  end

  for fp in all(fallenPoints) do
    local y = fp.y
    if (y > fp.destY) then
      y = fp.destY
    end
    if (fp.isTypeA) then
      drawBlockA(fp.x, fp.y, 7)
    else
      drawBlockA(fp.x, fp.y, 8)
    end
  end
end