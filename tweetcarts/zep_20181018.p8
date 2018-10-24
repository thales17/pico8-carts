pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

// https://twitter.com/lexaloffle/status/1052936770776514560

t=0 
r=64 
c=cos
::♥::
cls()
for i=0,300,0.15 do 
  x,y=c(i/30+t)+c(i/2+t*2)/9,sin(i/40)
  z=c(i/27+t)/1+2+sin(i/2+t*2)/9 
  pset(r+r*x/z,r+r*y/z,i/80+12)
end 
flip()
t += 1/200 
goto ♥
