pico-8 cartridge // http://www.pico-8.com
version 22
__lua__
-- DOOMFIRE
-- written by Adam Richardson

function _init()
	cls()
	for x=1,128 do
		pset(x-0,127,7)
		pset(x-0,126,7)
		pset(x-0,125,7)
	end
	pixels = {}
	for x=0,128 do
		for y=0,128 do
			local idx = y*128+x+1
			pixels[idx]=0
		end
	end
	for x=0,128 do
		local idx = 127*128+x+1
		pixels[idx]=7
	end
	colors = {
		0,
		5,
		2,
		13,
		1,
		10,
		15,
		4,
		14,
		9,
		3,
		11,
		12,
		8,
		6,
	}
end

function spread(src)
	local p = pixels[src]
	if(p == 0) then
		pixels[src-128]=0
	else
		local r = band(rnd(3),3)
		local dst = src - r + 1
		pixels[dst-128] = p-band(r,1) 
	end
end

function _update()
	for x=0,128 do
		for y=1,128 do
			spread(y*128+x)
		end
	end
end

function _draw()
	for x=0,128 do
		for y=0,128 do
			local idx = y*128+x+1
			pset(x,y,colors[pixels[idx]])
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
