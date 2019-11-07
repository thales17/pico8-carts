pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- invaders
-- written by Adam Richardson

function collide(r1, r2)
	return r1.x < (r2.x+r2.w) and
	  (r1.x+r1.w) > r2.x and
	  r1.y < (r2.y+r2.h) and
	  (r1.y+r2.h) > r2.y
end

function _init()
	t,s=0,20
	x=18
	pb={x=21,y=116,r=true,h=3,w=1,s=3}
	es={}
	for j=1,5 do
		for i=1,8 do
			e={x=18+(i-1)*12,y=(j-1)*12+18,w=8,h=8,st=0,f=1,sp={2,3},esp=18}
			add(es,e)
		end
	end  
end

function lefte()
	local l={x=128,y=128}
	for i=1,8 do
		local idx=(i-1)*8+1
		if(es[idx].st==0) then
			for j=1,8 do
				local e=es[idx+j]
				if(e.st==0 and l.x>e.x) then
					l.x=e.x
					l.y=e.y
					break
				end
			end
		elseif(l.x>es[idx].x) then
				l.x=es[idx].x
				l.y=es[idx].y
		end
	end
	
	return l
end

function righte()
	local r={x=0,y=0}
	for i=1,8 do
		local idx=(i-1)*8+1
		if(es[idx].st==0) then
			for j=1,8 do
				local e=es[idx+j]
				if(e.st==0 and r.x<e.x) then
					r.x=e.x
					r.y=e.y
					break
				end
			end	
		elseif(r.x<es[idx].x) then
			r.x=es[idx].x
			r.y=es[idx].y
		end
	end
	
	return l
end

function bottome(c)
	if(c<0 or c>8) return nil
end

function _update60()
	t=(t+1)%s
	if(t==0) then
		for e in all(es) do
			if(e.st==0) then
				e.f=e.f%#e.sp+1
			elseif(e.st==1) then
				e.f+=1
				if(e.f==1) e.st=2
			end
		end
	end
	if (btn(0)) then
		x-=1
		x=max(x,0)
	end
		
	if (btn(1)) then
		x+=1
		x=min(x,120)
	end

	if (btn(4)) then
		if(pb.r) then
			sfx(0)
			pb.r=false
			pb.x=x+3
			pb.y=116
		end
	end
	
	if (not pb.r) then
		pb.y-=pb.s
		if(pb.y<(-1*pb.h)) then
			pb.r=true
		end
		
		for e in all(es) do
			if(e.st==0 and collide(e,pb)) then
				pb.r=true
				e.st=1
				e.f=0
				t=0
				sfx(1)
			end
		end
	end
 
end

function _draw()
	cls(2)
	for e in all(es) do
		if(e.st==0) then
			spr(e.sp[e.f],e.x,e.y)
		elseif(e.st==1) then
			spr(e.esp,e.x,e.y)
		end
	end
	
	spr(4,x,118)
	if(not pb.r) then
		rectfill(pb.x,pb.y,pb.x+pb.w,pb.y+pb.h,7)
	end
end

__gfx__
00000000000000000070070000700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007700070077007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000077770070777707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007707707777077077000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007777777777777777077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007077770707777770077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000700007007000070777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000070070070000007777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000070070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000070070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001f050260502b050000000000000000000000000000000000001e000230002d0002b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002a65028650266502465024650206500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
