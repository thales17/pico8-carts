pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- written by Adam Richardson

function _init()
  firstDraw = true
end

function _update60()
  
end

function _draw()
  if (firstDraw) then
    cls(13)
    for i = 0,(128*128) do
      x = i % 128
      y = i / 128
      r = rnd(10)
      c = 0
      if (r < 5) then
        c = 13
      end
      pset(x,y,c)
    end
    firstDraw = false
    return
  end

  for i = 0,4000 do
    x = flr(rnd(128))
    y = flr(rnd(128))
    c = pget(x,y)
    if (c == 0) then
      c = 13
    else
      c = 0
    end
    pset(x,y,c)
  end
end