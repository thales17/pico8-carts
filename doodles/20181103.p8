pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- written by Adam Richardson

BouncyBall = {
  x = -10,
  y = -10,
  size = 2,
  color = 1 + flr(rnd(15)),
  xVel = rnd(2),
  yVel = 0,
  bounceVel = 0,
  bounces = 0,
  grav = 0.5,
}

function BouncyBall:reset()
  self.x = -10
  self.y = -10
  self.xVel = 0.2 + rnd(2)
  self.yVel = 0
  self.color = 1 + flr(rnd(15))
  self.bounces = 0
  self.bounceVel = 0
end

function BouncyBall:new(o)
  self.__index = self
  return setmetatable(o or {}, self)
end

function BouncyBall:update()
  self.x += self.xVel
  self.y += (self.yVel - self.bounceVel)

  if (self.y >= (128 - self.size)) then
    self.y = (128 - self.size)
    self.bounceVel = 10 - (self.bounces)
    self.yVel = 0
    self.bounces += 1
  end

  self.yVel += self.grav

  if (self.x >= 128) then
    self:reset()
  end
end

function BouncyBall:draw()
  local x = self.x
  local y = self.y
  local size = self.size
  local color = self.color
  circfill(x,y,size,color)
end

function _init()
  bouncyBalls = {}
  for i = 0,250 do
    local b = BouncyBall:new()
    b:reset()
    add(bouncyBalls, b)
  end
  first = true
end

function _update60()
  for b in all(bouncyBalls) do
    b:update()
  end
end

function _draw()
  -- if (first) then
  --   cls()
  --   first = false
  -- end
  cls()
  for b in all(bouncyBalls) do
    b:draw()
  end
end