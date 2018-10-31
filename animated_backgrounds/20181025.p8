pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- written by Adam Richardson

function _init()
  squareW = 8
  squareH = 4
  offsets = {}
  offsetAmount = {}
  for i = 0,(128/squareH) do
    offsets[i+1] = 0
    offsetAmount[i+1] = rnd(3) / 3
  end
end

function _update60()
  for i = 0,(128/squareH) do
    offsets[i+1] += offsetAmount[i+1]
    if (offsets[i+1] >= 128) then
      offsets[i+1] = 0
    end
  end
end

function drawSquare(x, y, color)
  rectfill(x,y,x+squareW,y+squareH,color)
  rect(x,y,x+squareW,y+squareH,6) 
end

function _draw()
  cls()
  for i=0,(256/squareW) do
    for j=0,(128/squareH) do
      drawSquare(i*squareW-offsets[j+1],j*squareH,12)
    end
  end
  
  
end