pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

// https://twitter.com/2DArray/status/992601223491600386

r=rnd
::_::
cls()
s=t()
srand(0) 
for i=1,60 do 
  x=(r(148)+sin(s/(3+r(3)))*5-s*(2+rnd(12))+10)%147-10 y=(r(148)+s*(3+r(8))+10)%147-10 u=sin(r()+s*r()/3) v=cos(r()+s*r()/3) 
  for j=-7,7 do circ(x+u*j-v*abs(j/4),y+v*j+u*abs(j/4),abs(u*v)*(7-abs(j))/1.5,3+j%2*8) 
  end 
end 
flip()
goto _