pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- CCCCCC
-- bY aDAM RICHARDSON

player={
	x=0,
	y=0,
	w=8,
	h=8,
	sidx=0,
	sdir=1,
	sw=1,
	sh=1,
	anim_t=0,
	flipping=false,
	should_flip=false,
	resting=false,
	anim_time=0.08}

grnd_s=3
exit_s=16
start_s=17
fire_s=18
star_s=19
v_enem_s=6
h_enem_s=4
level=0
start_grav=2
grav_speed=2
grav_mag=1
bg_c=0
blocks={}
exit={}
start={}
speed=1
bg_ticks=1
bg_t=0
bg_s=0
death=0

enemies={}
-->8
-- util
function collide(r1,r2)
	return r1.x<(r2.x+r2.w) and
		(r1.x+r1.w)>r2.x and
		r1.y<(r2.y+r2.h) and
		(r1.y+r1.h)>r2.y
end

function move_player(x,y)
	clear_rect({
		x=player.x,
		y=player.y,
		w=player.sw*8,
		h=player.sh*8,
	})
	player.x=x
	player.y=y
	spr(
		player.sidx,
		player.x,
		player.y,
		player.sw,
		player.sh,
		false,
		grav_mag<0)
end

function anim()
	if(player.anim_t+player.anim_time<t()) then
		player.anim_t=t()
		player.sidx+=player.sw*player.sdir
		if player.sidx>player.sw*2 then
			player.sidx=player.sw
			player.sdir*=-1
		end
		if player.sidx<0 then
			player.sidx=player.sw
			player.sdir*=-1
		end
	end
end

function clear_rect(r)
	rectfill(
		r.x,
		r.y,
		r.x+r.w,
		r.y+r.h,
		bg_c)
	local lvl_x=(level%8)
	local lvl_y=flr(level/8)
	map(lvl_x*16,lvl_y*16,0,0)
	for e in all(enemies) do
	rectfill(
		e.o.x,
		e.o.y,
		e.o.x+e.o.w,
		e.o.y+e.o.h,
		bg_c)
	end
end

function nomap_clear_rect(r)
	rectfill(
		r.x,
		r.y,
		r.x+r.w,
		r.y+r.h,
		bg_c)
end

-->8
-- starfield
star_cnt=25
function star_bg()
	if stars==nil then
		stars={}
		for i=1,star_cnt do
			local s=flr(rnd(2))
			add(stars,{
				x=128+flr(rnd(128-s)),
				y=flr(rnd(128-s))+s,
				r=s})
		end
	end
	cls(bg_c)
	for s in all(stars) do
		local spd=((s.r+2)/2)
		s.x-=spd
		if s.x<0 then
			s.x=128+flr(rnd(128-s.r))
			s.y=flr(rnd(128-s.r))
		end
		
		rectfill(
			s.x,
			s.y,
			s.x+s.r,
			s.y+s.r,7)
	end
end
-->8
-- fire
function init_fire()
	fw=64
	fh=12
	psize=3
	pixels={}
	for x=0,fw do
		for y=0,fh do
			pixels[idx_xy(x,y)]=0
		end
	end
	
	for x=0,fw-1 do
		pixels[idx_xy(x,fh-1)]=psize
	end
	
	colors={
		0,
		8,
		10}
end

function idx_xy(x,y)
	return y*fw+x+1
end

function update_fire()
	for i=0,(fw)*(fh-1) do
		local src=i+fw
		local p=pixels[src]
		if(p==0) then
			pixels[src-fw]=0
		else
			local r=band(flr(rnd(3)),3)
			local dst=src-r+1
			pixels[dst-fw]=p-band(r,1)  
		end
	end
end

function fire_bg()
	if pixels==nil then
		init_fire()
	end
	update_fire()
	local offset=128-fh
	for x=0,fw-1 do
		for y=0,fh-1 do
			for z=0,1 do
				pset(x+(z*63),y+offset,colors[pixels[idx_xy(x,y)]])
			end
		end
	end
end
-->8
-- game functions
function reset_player()
		move_player(start.x,start.y)
		grav_mag=1
		player.resting=false
		player.flipping=false
		player.should_flip=false
		death+=1
		sfx(2)
end

function fall()
	if player.resting then
		return
	end
	
	local r={
		x=player.x,
		y=player.y,
		w=player.w,
		h=player.h
	}
	r.y+=(grav_speed*grav_mag)
	player.flipping=true
	if r.x<0 then r.x=0 end
	if r.x>120 then r.x=120 end
	
	for b in all(blocks) do
		if collide(r,b) then
			player.resting=true
			player.flipping=false
			player.should_flip=false
			if grav_mag>0 then
				r.y=b.y-8
			else
				r.y=b.y+8
			end
			break
		end
	end
	
	move_player(r.x,r.y)
	
	if player.y<0 or
	player.y>120 then
		reset_player()
	end
end

function move_lr(s)
	local r={
		x=player.x+s,
		y=player.y,
		w=player.w,
		h=player.h}
	player.resting=false
	for b in all(blocks) do
		if collide(r,b) then
			if s<0 then
				r.x=b.x+b.w
			else
				r.x=b.x-r.w
			end
			break
		end
	end
	
	move_player(r.x,r.y)
end

function level_start()
	player.anim_t=0
	cls(bg_c)
	if level==16 then
		return
	end
	local lvl_x=(level%8)
	local lvl_y=flr(level/8)
	map(lvl_x*16,lvl_y*16,0,0)
	blocks={}
	enemies={}
	for i=0,15 do
		for j=0,15 do
			local x=lvl_x*16+i
			local y=lvl_y*16+j
			local s=mget(x,y)
			if s==grnd_s then
				add(blocks,{
					x=i*8,
					y=j*8,
					w=8,
					h=8
				})
			elseif s==exit_s then
				exit={
					x=i*8,
					y=j*8,
					w=8,
					h=8}
			elseif s==start_s then
				start={
					x=i*8,
					y=j*8,
					w=8,
					h=8}
			elseif s==star_s or
				s==fire_s then
				bg_s=s
			elseif s==v_enem_s or
				s==h_enem_s then
				add(enemies,{
					x=i*8,
					y=j*8,
					w=8,
					h=8,
					s=s,
					mag=1,
					o={
						x=i*8,
						y=j*8,
						w=8,
						h=8}})
			end
		end
	end
	player.x=start.x
	player.y=start.y
	grav_mag=1
	sfx(3)
end

function update_enemies()
	for e in all(enemies) do
		clear_rect(e)
		if collide(player,e) then
			reset_player()
		end
		if e.s==h_enem_s then
			e.x+=e.mag
		end
		
		if e.s==v_enem_s then
			e.y+=e.mag
			if e.y>128 then e.y=0 end
		end
		
		for b in all(blocks) do
			if collide(b,e) then
				e.mag*=-1
				sfx(1)
				break
			end
		end
		
		if e.x<0 or e.x>(128-e.w) or
			e.y<0 or e.y>(128-e.h) then
			e.mag*=-1
			sfx(1)
			break
		end
	end
end

-->8
-- p8 functions
function _init()
	level_start()
end

function _update60()
	if level==16 then return end
	if btn(⬅️) or btn(➡️) then
		if btn(➡️) then
			move_lr(speed)
		else
			move_lr(speed*-1)
		end
		anim()
	else
		player.sidx=1
	end
	
	if btnp(❎) and not player.flipping then
		grav_mag*=-1
		player.resting=false
		player.should_flip=true
		player.flipping=true
		sfx(0)
	end
	
	fall()
	update_enemies()
	if collide(player,exit) then
		level+=1
		level_start()
	end
end

function _draw()
	if level==16 then
		cls(1)
		print("you win!",50,50,7)
		return
	end
	bg_t+=1
	if bg_t==bg_ticks then
		bg_t=0
		if bg_s==star_s then
			star_bg()
		elseif bg_s==fire_s then
			fire_bg()
		end
		move_player(player.x,player.y)
		pset(127,0,0)
		for e in all(enemies) do
			local s=e.s
			if e.mag<0 then s+=1 end
			spr(s,e.x,e.y)
		end
	end
	print(level,0,0,7)
	print(death,120,0,8)
end
__gfx__
000bb000000bb000000bb00004445440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bb000000bb000000bb00045454444009999000099990000666600006666000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbb54444454097070900907079006066060060660600000000000000000000000000000000000000000000000000000000000000000
b00bb00bb00bb00bb00bb00b45444545099999900999999006666660066666600000000000000000000000000000000000000000000000000000000000000000
000bb000000bb000000bb00054454444099999900999999006600660066666600000000000000000000000000000000000000000000000000000000000000000
00bbbb0000bbbb0000bbbb0044444544099009900990099006600660066006600000000000000000000000000000000000000000000000000000000000000000
00b00bb000b00b000bb00b0045445445009999000099990000666600006666000000000000000000000000000000000000000000000000000000000000000000
0bb000000bb00bb000000bb004454440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000800000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccc0022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccc0022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccc0022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c6cccc0026222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccc0022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccc0022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccc0022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
70000000000000000bb0000000000000000000000000000000000000044454400444544004445440044454400444544004445440044454400444544088800000
70000000000000000bb2222000000000000000000000000000000000454544444545444445454444454544444545444445454444454544444545444480800000
77700000000000bbbbbbbb2000000000000000000000000000000000544444545444445454444454544444545444445454444454544444545444445480800000
70700000000000b00bb22b2000000000000000000000000000000000454445454544454545444545454445454544454545444545454445454544454580800000
77700000000000000bb2222000000000000000000000000000000000544544445445444454454444544544445445444454454444544544445445444488800000
0000000000000000bbbb222000000000000000000000000000000000444445444444454444444544444445444444454444444544444445444444454400000000
0000000000000000b22b222000000000000000000000000000000000454454454544544545445445454454454544544545445445454454454544544500000000
000000000000000bb22bb22000000000000000000000000000000000044544400445444004454440044544400445444004454440044544400445444000000000
00000000044454400444544004445440000000000000000000000000044454400000000000000000000000000000000000000000000000000000000000000000
00000000454544444545444445454444000000000000000000000000454544440000000000000000000000000000000000000000000000000000000000000000
00000000544444545444445454444454000000000000000000000000544444540000000000000000000000000000000000000000000000000000000000000000
00000000454445454544454545444545000000000000000000000000454445450000000000000000000000000000000000000000000000000000000000000000
00000000544544445445444454454444000000000000000000000000544544440000000000000000000000000000000000000000000000000000000000000000
00000000444445444444454444444544000000000000000000000000444445440000000000000000000000000000000000000000000000000000000000000000
00000000454454454544544545445445000000000000000000000000454454450000000000000000000000000000000000000000000000000000000000000000
00000000044544400445444004454440000000000000000000000000044544400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000044454400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000454544440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000544444540000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000700000000000000454445450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000544544440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444445440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000454454450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000044544400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000044454400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000454544440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000544444540000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000454445450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000544544440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444445440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000454454450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000044544400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000044454400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000999900054544440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000009070790044444540000000000000000000000000000077000000000000000000000000000000000
00000000000000000000000000000000000000000000000009999990054445450000000000000000000000000000077000000000000000000000000000000000
00000000000000000000000000000000000000000000000009999990044544440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000009900990044445440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000999900054454450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000044544400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000044454400000000000000000000000000000000000000000044454400000000000000000
00000000000000000000000000000000000000000000000000000000454544440000000009999000000000000000000000000000054544440000000000000000
00000000000000000000000000000000000000000000000000000000544444540000000090707900000000000000000000000000044444540000000000000000
00000000000000000000000000000000000000000000000000000000454445450000000099999900000000000000000000000000054445450000000000000000
00000000000000000000000000000000000000000000000000000000544544440000000099999900000000000000000000000000044544440000000000000000
00000000000000000000000000000000000000000000000000000000444445440000000099009900000000000000000000000000044445440000000000000000
00000000000000000000000000000000000000000000000000000000454454450000000009999000000000000000000000000000054454450000000000000000
00000000000000000000000000000000000000000000000000000000044544400000000000000000000000000000000000000000044544400000000000000000
00000000000000000000000000000000000000000000000000000000044454400000000000000000000000000000000000000000044454400000000000000000
0000000000000000000000000000000000000000000000000000000045454444000000000000000000000000000000000cccccc0454544440000000000000000
0000000000000000000000000000000000000000000000000000000054444454000000000000000000000000000000000cccccc0544444540000000000000000
0000000000000000000000000000000000000000000000000000000045444545000000000000000000000000000000000cccccc0454445450000000000000000
0000000000000000000000000000000000000000000000000000000054454444000000000000000000000000000000000c6cccc0544544440000000000000000
0000000000000000000000000000000000000000000000000000000044444544000000000000000000000000000000000cccccc0444445440000000000000000
0000000000000000000000000000000000000000000000000000000045445445000000000000000000000000000000000cccccc0454454450000000000000000
0000000000000000000000000000000000000000000000000000000004454440000700000000000000000000000000000cccccc0044544400000000000000000
00000000000000000000000000000000000000000000000000000000044454400000000000000000000000000444544004445440044454400000000000000000
00000000000000000000000000000000000000000000000000000000454544440000000000000999900000004545444445454444454544440000000000000000
00000000000000000000000000000000000000000000000000000000544444540000000000009707090000005444445454444454544444540000000000000000
00000000000000000000000000000000000000000000000000000000454445450000000000009999990000004544454545444545454445450000000000000000
00000000000000000000000000000000000000000000000000000000544544440000000000009999990000005445444454454444544544440000000000000000
00000000000000000000000000000000000000000000000000000000444445440000000000009900990000004444454444444544444445440000000000000000
00000000000000000000000000000000000000000000000000000000454454450000000000000999900000004544544545445445454454450000000000000000
00000000000000000000000000000000000000000000000000000000044544400000000000000000000000000445444004454440044544400000000000000000
00000000000000000000000000000000000000000000000000000000044454400000000000000000000000000000000000000000000000000000000000000000
00000000000000099990000000000000000000000000000000000000454544440000000000000000000000000000000000000000000000000000000000000000
00000000000000970709000000000000000000000000000000000000544444540000000000000000000000000000000000000000000000000000000000000000
00000000000000999999000000000000000000000000000000000000454445450000000000000000000000000000000000000000000000000000000000000000
00000000000000999999000000000000000000000000000000000000544544440000000000000000000000000000000000000000000000000000000000000000
00000000000000990099000000000000000000000000000000000000444445440000000000000000000000000000000000000000000000000000000000000000
00000000000000099990000000000000000000000000000000000000454454450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000044544400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000044454400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000454544440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000544444540000000000000000000000000007000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000454445450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000544544440000000000000000000000000000000000000000000070000000000000000000
00000000000000000000000000000000000000000000000000000000444445440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000454454450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000044544400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000044454400000000000000000000000000000000000000007000000000000000000000000
00000000000000000000000000000000000000000000000000000000454544440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000007000000000000000000000000544444540000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000454445450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000544544440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444445440000000000000000000000000000000000000000000000000000000000000000
00000070000000000000000000000000000000000000000000000000454454450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000044544400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000044454400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000454544440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000544444540000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000454445450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000544544440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000444445440000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000454454450000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000044544400000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000770000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04445440044454400444544004445440044454400444544004445440044454400444544004445440044454400444544004445440044454400444544004445440
45454444454544444545444445454444454544444545444445454444454544444545444445454444454544444545444445454444454544444545444445454444
54444454544444545444445454444454544444545444445454444454544444545444445454444454544444545444445454444454544444545444445454444454
45444545454445454544454545444545454445454544454545444545454445454544454545444545454445454544454545444545454445454544454545444545
54454444544544445445444454454444544544445445444454454444544544445445444454454444544544445445444454454444544544445445444454454444
44444544444445444444454444444544444445444444454444444544444445444444454444444544444445444444454444444544444445444444454444444544
45445445454454454544544545445445454454454544544545445445454454454544544545445445454454454544544545445445454454454544544545445445
04454440044544400445444004454440044544400445444004454440044544400445444004454440044544400445444004454440044544400445444004454440
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000077000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000077000000000000000000000000000000000000000000000000000000000000000000

__gff__
0080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000001300000000000000000000000000000013000000000303030303000000000000123f00003f0003030303030000030303120000003f0000000000000000000000130303030303030303030303030303031300001100000000030303030303030313003f0000000000000000000000000012
000000000000000000000000000000000000000000000000000000000000000000000000030000060000000000003f003f3f000000000000000000000000000000000000000000001100000000000000003f00030000000000003f00000000000003030300000003000000000000000000000000000000000303030303000000
00000000000000000000000000000000000000000000000000000000000000000000000003003f0000000303033f3f003f3f3f00000000000000000000000000000000000000000303030000000000003f3f3f030000000000000000003f00000000000000000003000000000000000000000000000000000300000000000000
000000000000000000000000000000000000000000000000000000000000000000000000030000000000003f3f3f000000003f00000000000000000000000000000000000000000000060000000000000000000300000000000000000003000000000000000000033f0000000000000000000000000000000300000004000000
0000000000000000000000000000000000000000000303030000000000000000000000000300000000003f3f3f0000000303030304000000000000000000000000000000000000000000000000000000103f3f3f0400000000000000000300000000000000000403000000000000000000000000000000110310000000000000
00000000000000000000000000000000110000000000000000000000000000000000000003100000003f3f3f3f00000000003f3f3f00000000000000000000000000030303030000000000030303030303030303030303030303030303033f3f0000000000000003000000000403000003030303030003030303030000000000
000000000000000000000000000000000303030000000000000000000000000000000000030303033f3f000000000000000000003f3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000001003000000000000000000000300000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000003f0000000000000000110000003f03030304000000000000000000003f0000000000000000000000000000000000000000000000000000000000000000000003040000030303000003000303030303030300000003030300
0000000000000000000000000000000000000000000000000303030400000000000000000000003f3f00000000000000000000000000003f000000000000000000000000000000061000000000000000000003030303030303030303030303030004000000000003000000000000000000000000000000000300000000000000
00000000000000063f3f000000000000000000000000000000000000000000001100000000003f3f3f00000000000000000000000000003f3f3f0003000000000000000000000003030300000000000000003f000000000000000000000000000000000000000003000000000000000003030303030003030300000000000000
0000003f3f3f000000000000000000003f000000003f00000000000000001000030303003f3f3f3f00000000000000000000000000000000003f00030000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000003000000000000000000
00000000000000000000000000000000000000030303000000000000030303000000003f3f3f3f0000000000000000000303030300000000003f3f030000000000000000000000000000000000000000000000000000000000003f00000000000000000000000003000000000000000003033f03030303000300000000000000
000000000000000000003f3f0000000000003f3f003f000000000000003f3f3f0000003f3f3f00000000000000000000000000000000000000003f033f00100000000000000000000000000000000000001100000000000000003f3f000000040000000000000000000000000000000000000000000000003f00000000000000
00000000003f3f3f0000000000000000003f3f3f003f3f3f0000003f3f3f3f3f003f3f3f000000000000000000000000000000003f3f3f3f3f0000030303030000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030300000303000000000000000000000000
1100003f3f3f3f000000000000000010003f3f00003f3f3f3f3f3f3f3f3f3f3f3f3f000303030000000000000000000000003f3f00000000000000003f3f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
030303030303030303030303030303033f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0000000000000000000000000000000000000000000000000000003f3f3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000130011030303030303030000000303001200000000000000000000000000000013030303030003030303030300000000120000000303000000000000000300001300000000000000000000000000000012000000000000000000000000000000133f000000000000000000000000000012
00000000000000030000000000000000000303103f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000031100000000000000000000003f00000000000000000003030000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000030303030303030303000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000303001100000000000000003f0000000000000000000000000000000000000000000011000000000000000000000000000000
00000000000000000000000000000000030300030000003f000000000000000000000303030000000000003f0000000010000000000000000000000000000000000000000000000000000000000003000300000000003f003f000000000000000000000000000000000000000000000003030304000000000303030300000000
00000000030000000000000000000000000000030000003f000000000000000000000300000400000000000303000000030303040000000300000000000000000000000000000000000000000000000010030000003f3f3f00003f3f3f0000000000030400000003030000000000000000000000000000000300000000000000
0000000000000000000000000003000000030303000000030303000000000000000000000000030303000000030000000000000000000000000000000000000000000000000000000003030000000003000003003f3f3f0000003f3f0000003f0000000000000000000000000000000000000000000000000300000000000000
000000000000000000000300000000000000000000000000000000000000000000000003003f000004000010030000000000000000000000000000000000000000000000000000000000000000000000000000033f000000000403000000000000030000003f0000040303000000000000000000000000000600000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000303030000000000000000000000000000000000001100001006000000000000000000030000040000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000030303033f3f00000000000000000000000000000000000000000000000000000000000000030000000000030303030300000303000000000000000000000000000000000003000000000000000000000000000000000000000000030303000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003003f000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000003f00000000000000000000000000000003000000000000001100000000000000000300000000000000
11000000060000060000060000060010000000000003030300030303000303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f0300000000000000000000001000000000000000000004030300000000000000000000000000000000
030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003f000000000000000000000000000303000003030000000000000000000000000000001000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300001114016120120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000f0200f020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000900002203021030100300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000b00000c0301b030120300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
