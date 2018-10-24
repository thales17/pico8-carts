pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

::★:: 
for y=0,31 do 
  for x=0,31 do 
    u=x*4 
    v=y*4 
    d=sqrt((16-x)^2+(16-y)^2) 
    q=1+cos(d/(t()-5)-t()/2)*0.9 
    fillp(8580+(flr(q)%2)*9870) 
    rectfill(u,v,u+3,v+3,0x81) 
  end 
end 
flip() 
goto ★