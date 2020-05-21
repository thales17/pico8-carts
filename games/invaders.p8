pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- INVADERS
-- BY ADAM RICHARDSON
player={
	x=0,
	y=120,
	w=11,
	h=8}
score=0
lives=2
ufo={x=-20,y=10,w=16,h=8}
enemy_ticks=10
eticks=0
enemies={}
pb={
	x=0,
	y=120,
	w=1,
	h=4,
	speed=2,
	active=false}
animations={}
erow=3
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
gameover=false
round=1
round_ticks=100
rticks=0
playing=false
dying=false
die_ticks=40
dticks=0
ufo_ticks=500
uticks=0
esfx=0
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

function clear_to_shoot(idx)
	local a=enemies[idx]
	for i=idx+1,#enemies do
		local b={
			x=enemies[i].x,
			y=a.y,
			w=enemies[i].w,
			h=enemies[i].h
		}
		
		if box_collide(a,b) then
			return false
		end
	end
	
	return true
end

function enemy_shoot()
	if eb.active then
		return
	end
		
	local idx=flr(rnd(min(6,#enemies)))
	local e=enemies[#enemies-idx]
	if clear_to_shoot(#enemies-idx) then
		eb.active=true
		eb.x=e.x+5
		eb.y=e.y+8
	end
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
	if erow<0 then erow=3 end
	
	if erow==3 then
		enemy_shoot()
		sfx(esfx)
		if esfx==0 then
			esfx=1
		else
			esfx=0
		end
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
			if #enemies%3==0 then
				enemy_ticks-=2
			end
			score+=e.score
			sfx(3)
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
		score+=100
		sfx(5)
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
		lives-=1
		gameover=lives<0
		if gameover then
			lives=0
		end
		dying=true
		dticks=0
		clear_rect(pb)
		pb.active=false
		sfx(4)
		return true
	end
	return false
end

function round_start()
	cls()
	print("round "..round,51,60,7)
	rticks=0
	playing=false
end

function round_play()
	edirs={1,1,1,1,1}
	edrops={0,0,0,0,0}
	dcount=0
	animations={}
	ufo={x=-20,y=10,w=16,h=8}
	eticks=0
	player={x=0,y=120,w=11,h=8}
	enemy_ticks=10
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
			row=0,
			score=30
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
			row=1,
			score=20
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
			row=3,
			score=10
		})
	end
	
	-- player
	spr(10,player.x,player.y,2,1)
	
	-- sheilds
	for i=0,3 do
		spr(34,8+i*32,100,2,2)
	end
end
-->8
function _init()
	round_start()
end


function _update60()
	if gameover then
		animate()
		return
	end
	
	if not playing and 
		rticks<round_ticks then
		rticks+=1
		if rticks==round_ticks then
			playing=true
			round_play()
		end
		return
	end
	
	if dying 
		and dticks<die_ticks then
		dticks+=1
		if dticks==die_ticks then
			dying=false
			player.x=0
			spr(10,player.x,player.y,2,1)
		end
		animate()
		return
	end
	
	eticks+=1
	if eticks>=enemy_ticks then
		eticks=0
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
	
	
	if uticks==ufo_ticks then
		clear_rect(ufo)
		ufo.x+=1
		spr(32,ufo.x,ufo.y,2,1)
		if ufo.x>128 then
			ufo.x=-20
			uticks=0
		end
	else
		uticks+=1
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
		sfx(2)
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
	if #enemies==0 then
		round+=1
		round_start()
	end
end

function _draw()
	rectfill(0,0,128,10,0)
	-- info
	print("score "..score,45,2,7)
	spr(10,104,0,2,1)
	print("="..lives,116,2,7)
		
--	print(stat(1),0,2,7)
	
	if gameover then
		print("game over",50,50,8)
	end
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
0002000001320063201c7000c7000c70000000000000000000000000001e000230002d0002b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000632001320040002460024600206000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002b330013000f3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000203301c330143300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007000021650126500a6500265003650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600001135016350223500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
