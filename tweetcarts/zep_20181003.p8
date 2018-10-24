pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

::★::
cls()
q=3.3+sin(t()/20)*1.7 
local p=t()*3 
for i=0x6000,0x7fff do 
  poke(i,band(p,119.891)+0x77) 
  p=p+cos(i/63.247)+cos(i/64.260)*q 
end 
flip() 
goto ★