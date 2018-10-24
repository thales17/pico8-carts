pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

// https://twitter.com/2DArray/status/1053310341873102848

::_::
x=rnd(128)
y=rnd(128)
pset(x,y,((x+y)/8+sin(x/40+t()/8)+cos(y/40+t()/8)+rnd())%3+5)
goto _
