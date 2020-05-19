pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- INVADERS
-- BY ADAM RICHARDSON
player={x=0,y=120,w=11,h=8}
score=0
lives=0
ufo={x=-20,y=10,w=16,h=8}
enemy_ticks=1
ticks=0
enemies={}
pb={
	x=0,
	y=120,
	w=1,
	h=4,
	speed=2,
	active=false}
animations={}
erow=4
edirs={1,1,1,1,1}
edrops={0,0,0,0,0}
drop=2
dcount=0
shields={
	{
		x=8,
		y=100,
		w=16,
		h=16,
	},
	{
		x=40,
		y=100,
		w=16,
		h=16,
	},
	{
		x=72,
		y=100,
		w=16,
		h=16,
	},
	{
		x=104,
		y=100,
		w=16,
		h=16,
	},
}
eb={
	x=0,
	y=0,
	w=1,
	h=4,
	speed=2,
	active=false
}
-->8
function clear_rect(r)
	local w=r.w
	-- prevent the bullet from being too wide
	if w==1 then w=0 end
	rectfill(
		r.x,
		r.y,
		r.x+w,
		r.y+r.h,0)
end

function enemy_shoot()
	if eb.active then
		return
	end
	-- build a set of the bottom most enemies
	-- randomly pick one
	-- set the eb.x,y to this location
	-- set eb.active
	eb.active=true
	eb.x=50
	eb.y=50
end

function update_enemies()
	local next_spr={
		e=5,
		f=4,
		a=2,
		c=0,
		g=8,
		i=6
	}
	local end_reached=false
	local edidx=0
	for e in all(enemies) do
		if e.row>erow then break end
		
		if e.row==erow then
			clear_rect(e)
			e.x+=edirs[e.didx]
			e.s=next_spr[chr(ord("a")+e.s)]
			spr(e.s,e.x,e.y,e.sw,e.sh)
			if e.x+e.w>127 or e.x<1 then 
				end_reached=true
				edidx=e.didx
				edrops[edidx]+=1
			end
		end
	end
	
	if end_reached then
		if edrops[edidx]>dcount then
			dcount+=1
			for e in all(enemies) do
					clear_rect(e)
					e.y+=drop
					spr(e.s,e.x,e.y,e.sw,e.sh)
			end
		end
		local v=edirs[edidx]
		edirs[edidx]=-1*v
	end
	
	erow-=1
	if erow<0 then erow=4 end
	
	if erow==4 then
		enemy_shoot()
	end
end

function box_collide(r1,r2)
	return (r1.x < r2.x+r2.w) and
		(r1.x+r1.w > r2.x) and
		(r1.y < r2.y+r2.h) and
		(r1.y+r1.h > r2.y)
end

function explosion(x,y)
	add(animations,{
		states={
			{
				s=12,
				eframe=9
			},
			{
				s=14,
				eframe=16
			}
		},
		frame=0,
		tframes=16,
		state_idx=1,
		x=x,
		y=y,
		w=12,
		h=8,
		sw=2,
		sh=1,
	})
end

function animate()
	for a in all(animations) do
		clear_rect(a)
		if a.frame < a.tframes then
			a.frame+=1
			if a.frame < a.tframes then
				local eframe = a.states[a.state_idx].eframe
				if a.frame==eframe then
					a.state_idx+=1
				end
			end
			spr(
				a.states[a.state_idx].s,
				a.x,
				a.y,
				a.sw,a.sh)
		else
			del(animations,a)
		end
	end
end

function kill_enemies()
	for e in all(enemies) do
		if box_collide(e,pb) then
			clear_rect(e)
			del(enemies,e)
			explosion(e.x,e.y)
			return true
		end
	end
	
	return false
end

function kill_ufo()
	if box_collide(pb,ufo) then
		clear_rect(ufo)
		explosion(ufo.x,ufo.y)
		ufo.x=-20
		return true
	end
	
	return false
end

function shield_player()
	for s in all(shields) do
		if box_collide(pb,s) then
			if pget(pb.x,pb.y-1)==12 then
				pset(pb.x,pb.y-1,0)
				return true
			end			
		end
	end
	return false
end

function shield_enemy()
	for s in all(shields) do
		if box_collide(eb,s) then
			if pget(eb.x,eb.y+eb.h+1)==12 then
				pset(eb.x,eb.y+eb.h+1,0)
				return true
			end			
		end
	end
	return false
end

function kill_player()
	if box_collide(eb,player) and
		eb.active then
		clear_rect(player)
		explosion(player.x,player.y)
		return true
	end
	return false
end

-->8
function _init()
	cls()
	-- ufo
	spr(32,ufo.x,ufo.y,2,1)
	
	-- enemies
	for i=0,6 do
		local x=i*16
		spr(4,x+2,20)
		add(enemies,{
			x=x+2,
			y=20,
			w=8,
			h=8,
			s=4,
			sw=1,
			sh=1,
			didx=1,
			row=0
		})
	end
	
	for i=0,6 do
		local x=i*16
		spr(0,x+1,35,2,1)
		add(enemies,{
			x=x+1,
			y=35,
			w=11,
			h=8,
			s=0,
			sw=2,
			sh=1,
			didx=2,
			row=1
		})
	end
	
	for i=0,6 do
		local x=i*16
		spr(6,x,50,2,1)
		add(enemies,{
			x=x,
			y=50,
			w=12,
			h=8,
			s=6,
			sw=2,
			sh=1,
			didx=4,
			row=3
		})
	end
	
	-- player
	spr(10,player.x,player.y,2,1)
	
	-- sheilds
	for i=0,3 do
		spr(34,8+i*32,100,2,2)
	end
end


function _update60()
	ticks+=1
	if ticks>=enemy_ticks then
		ticks=0
		update_enemies()
	end
	
	if btn(0) then
		clear_rect(player)
		player.x-=1
		player.x=max(0,player.x)
		spr(10,player.x,player.y,2,1)
	end
	
	if btn(1) then
		clear_rect(player)
		player.x+=1
		player.x=min(128-player.w,player.x)
		spr(10,player.x,player.y,2,1)
	end
	
	clear_rect(ufo)
	ufo.x+=1
	spr(32,ufo.x,ufo.y,2,1)
	if ufo.x>128 then
		ufo.x=-20
	end
	
	if pb.active then
		clear_rect(pb)
		pb.y-=pb.speed	
		rectfill(
			pb.x,
			pb.y,
			pb.x,
			pb.y+pb.h,11)
		if pb.y<=10 then
			clear_rect(pb)
			pb.active=false
		end
		
		if kill_enemies() then
			clear_rect(pb)
			pb.active=false
		else
			if kill_ufo() then
				clear_rect(pb)
				pb.active=false
				else
					if shield_player() then
						clear_rect(pb)
						pb.active=false
					end
			end
		end
	end
	
	if btnp(5) and not pb.active then
		pb.active=true
		pb.y=115
		pb.x=player.x+5
	end
	
	if eb.active then
		clear_rect(eb)
		eb.y+=eb.speed
		rectfill(
			eb.x,
			eb.y,
			eb.x,
			eb.y+eb.h,7)
		if shield_enemy() then
			clear_rect(eb)
			eb.active=false
		else
			if kill_player() then
				clear_rect(eb)
				eb.active=false
				-- check lives
			end
		end
		
		if eb.y>128 then
			clear_rect(eb)
			eb.active=false
		end
	end
	
	animate()
end

function _draw()
	rectfill(0,0,128,10,0)
	-- info
	print("score "..score,45,2,7)
	spr(10,104,0,2,1)
	print("="..lives,116,2,7)
		
	print(stat(1),0,2,7)
end
__gfx__
0070000070000000007000007000000000077000000770000000777700000000000077770000000000000b000000000000000000000000000000000000000000
000700070000000070070007007000000077770000777700077777777770000007777777777000000000bbb00000000000000000000000000007007007000000
007777777000000070777777707000000777777007777770777777777777000077777777777700000000bbb00000000000000000000000000000700070000000
077077707700000077707770777000007707707777077077777007700777000077700770077700000bbbbbbbbb00000000000070000000000000007000000000
77777777777000000777777777000000777777777777777777777777777700007777777777770000bbbbbbbbbbb0000000000777000000000077077707700000
70777777707000000077777770000000070770700070070000777007770000000007700770000000bbbbbbbbbbb0000000000070000000000000007000000000
70700000707000000070000070000000700000070707707007700770077000000077077077000000bbbbbbbbbbb0000000000000000000000000700070000000
00077077000000000700000007000000070000707070070700770000770000007700000000770000bbbbbbbbbbb0000000000000000000000007007007000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000088888800000000cccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000888888888800000cccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888888888888000cccccccccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0880880880880880cccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888888888888888cccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0088800880088800cccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000000008000cccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cccccc0000cccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000ccccc000000ccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cccc00000000cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cccc00000000cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001f050260502b050000000000000000000000000000000000001e000230002d0002b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002a65028650266502465024650206500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
