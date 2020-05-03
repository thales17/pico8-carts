pico-8 cartridge // http://www.pico-8.com
version 23
__lua__
-- CONWAY'S GAME OF LIFE
-- BY ADAM RICHARDSON

function _init()	
	gaddr=0X4300
	size=4
	cols=128/size
	gsize=(cols*cols)/8
	laddr=gaddr+gsize
	rndg()
end

function rndg()
	memset(gaddr,0X0,gsize)
	for idx=0,gsize do
		local v=rnd(0Xff)
		poke(gaddr+idx,v)
		poke(laddr+idx,v)
	end
	for x=0,cols-1 do
		set_xy(x,0,0)
		set_xy(x,cols-1,0)
		set_xy(0,x,0)
		set_xy(cols-1,x,0)
	end
	lt=t()
end

function state_xy(x,y)
	local idx=(y*cols+x)
	local i=idx/8
	local o=(idx%8)
	local m=shl(1,o)
	local v=peek(laddr+i)
	
	return band(m,v) > 0
end

function set_xy(x,y,n)
	local idx=(y*cols+x)
	local i=idx/8
	local o=(idx%8)
	local m=shl(1,o)
	local v=peek(gaddr+i)
	if(n==0) then
		m=bnot(m)
		poke(gaddr+(i),band(m,v))
	else
		poke(gaddr+(i),bor(m,v))
	end
end

function score(x,y)
	local s=0
	-- north
	if state_xy(x,y-1) then
		s+=1
	end
	-- north east
	if state_xy(x+1,y-1) then
		s+=1
	end
	-- north west
	if state_xy(x-1,y-1) then
		s+=1
	end
	-- south
	if state_xy(x,y+1) then
		s+=1
	end
	-- south east
	if state_xy(x+1,y+1) then
		s+=1
	end
	-- south west
	if state_xy(x-1,y+1) then
		s+=1
	end
	-- east
	if state_xy(x+1,y) then
		s+=1
	end
	-- west
	if state_xy(x-1,y) then
		s+=1
	end
	return s
end

function _update60()
	if btn(1) then
		rndg()
		return
	end
	for x=1,cols-2 do
		for y=1,cols-2 do
			local s=score(x,y)
			local st=state_xy(x,y)
			
			if st then
				if s<2 or s>3 then
					set_xy(x,y,0)
				end
			else
				if s==3 then
					set_xy(x,y,1)
				end
			end
		end
	end
	
	memcpy(laddr, gaddr, gsize)
end

function _draw()
	cls()
	local x=0
	local y=0
	
	for idx=0,gsize do
		local v=peek(gaddr+idx)
		for o=0,7 do
			local m=shl(1,o)
			if band(m,v) > 0 then
				rectfill(
					x*size,
					y*size,
					x*size+size-1,
					y*size+size-1,
					11)
			end
			x+=1
			if(x==cols) then
				x=0
				y+=1
			end
		end
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
