pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

Stripe = {
  left = true,
  color = 7,
  speed = 1,
  y = 0,
  width = 0,
  height = 10,
  done = false
}

function Stripe:new(o)
  self.__index = self
  return setmetatable(o or {}, self)
end

function Stripe:reset()
  local leftOrRight = rnd(10)
  if (leftOrRight > 5) then
    self.left = false
  else
    self.left = true
  end
  self.color = 3 + ceil(rnd(12))
  self.width = 0
  self.done = false
  self.speed = 1 + flr(rnd(3))
end

function Stripe:update()
  if (self.done) then
    return
  end
  self.width += self.speed
  if(self.width >= 256) then
    self.width = 128
    self.done = true
    self:reset()
  end
end

function Stripe:draw()
  if (self.left) then
    rectfill(0,self.y,self.width,self.y + self.height,self.color)
  else
    rectfill(128,self.y,128-self.width,self.y+self.height,self.color)
  end
end

function _init()
  stripes = {}

  for i = 0,12 do
    local s = Stripe:new()
    s.y = i * s.height
    s:reset()
    add(stripes, s)
  end
end

function _update60()
  for s in all(stripes) do
    s:update()
  end
end

function _draw()
  cls()
  for s in all(stripes) do 
    s:draw()
  end
end