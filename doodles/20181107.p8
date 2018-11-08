pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

function _init()
  yOffset = 0
end

function _update60()
  yOffset += 1
  if (yOffset >= 128) then
    yOffset = 0
  end
end

function drawTriangle(x,y,size,color)
  line(x,y,x+size,y,color)
  line(x+size,y,x+(size/2),y+(size),color)
  line(x+(size/2),y+(size),x,y,color)
end

function _draw()
  cls(6)
  for i = 0,162 do
    local c = i % 9
    local r = flr(i / 9)

    color = 0
    if (r % 2 > 0) then
      c -= 0.5
      drawTriangle(c*16,r*16-yOffset,16,color)
    end
    drawTriangle(c*16,r*16-yOffset,16,color)
  end 
  
end