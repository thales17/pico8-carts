pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

function _init()
  percent = 0
end

function _update60()
  percent += 0.01
  if (percent >= 1) then
    percent = 0
  end
end

function _draw()
  cls()
  for i=0,50 do
    line(0-i,0-i,(64*(percent/0.5))-i,(128*(percent/0.5))-i,(i%15))
    if (percent >= 0.5) then
      line(64-i,128-i,64+(64*((percent-0.5)/0.5))-i,128-(128*((percent-0.5)/0.5))-i,(i%15))
    end
  end
end