pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

function _init()
  maxRadius = 100
  radius = maxRadius
  circCount = 100
  rDir = -1
end

function _update60()
  radius += rDir
  if (radius < (-1 * circCount)) then
    rDir *= -1
  end

  if (radius > (maxRadius)) then
    rDir *= -1
  end
end

function _draw()
  cls()
  for i = 0,circCount do
    circfill(64,64,radius+(circCount-i),(i%16))
  end
end