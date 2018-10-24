pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

function _init()
  angle = 0
  amp =  8
  freq = 1
  freqDir = 1
end

function _update60()
  angle += 0.001
  angle %= 1
  freq += (0.002 * freqDir)
  if (freq >= 5 or freq <= 0) then
    freqDir *= -1
  end
end

function _draw()
  cls(12)
  for i = 0,12 do
    y = i * 10
    for x = 0,128 do
      xAng = angle + (x * 0.003)
      xAng %= 1
      z = sin(freq * xAng) * amp
      -- print(z,0,0,7)
      pset(x, 4 + y + z, 6)
      pset(4 + y + z, x, 6)
      -- pset(4+y,x,6)
    end
  end
end