pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- MAZE
-- BY ADAM RICHARDSON
-- INSIRED BY ONE LONE CODE: PROGRAMMING MAZES
-- https://www.youtube.com/watch?v=y37-gb83hke

size=4
cols=128/size
rows=128/size

not_visited=0
east_path=1
west_path=2
south_path=3
north_path=4

grid={}
visited_count=0

function stack()
	return {
		x=0,
		y=0,
		n=nil,
	}
end

top=stack()

function _init()
	for i=1,(cols*rows) do
		grid[i]=not_visited
	end
	top.x=0
	top.y=0
	top.n=nil
	visited_count=1
	grid[0]=east_path
end

function idx_xy(x,y)
	return y*cols+x
end

function next_point(x,y)
	local r=flr(rnd(4))
	local xy={
		x=x,
		y=y,
	}
	if r==0 then
		if xy.y>0 then
			xy.y-=1
		end
	elseif r==1 then
		if xy.y<(rows-1) then
			xy.y+=1
		end
	elseif r==2 then
		if xy.x<(cols-1) then
			xy.x+=1
		end
	elseif r==3 then
		if xy.x>0 then
			xy.x-=1
		end
	end
	return xy
end

function has_not_visited_neighbors()
	if top.y>0 then
		if grid[idx_xy(top.x,top.y-1)]==not_visited then
			return true
		end
	end
	
	if top.y<(rows-1) then
		if grid[idx_xy(top.x,top.y+1)]==not_visited then
			return true
		end
	end
	
	if top.x>0 then
		if grid[idx_xy(top.x-1,top.y)]==not_visited then
			return true
		end
	end
	
	if top.x<(cols-1) then
		if grid[idx_xy(top.x+1,top.y)]==not_visited then
			return true
		end
	end
	
	return false
end

function advance_point()
	if has_not_visited_neighbors() then
		local xy=next_point(top.x,top.y)
		local idx=idx_xy(xy.x,xy.y)
		while grid[idx] != not_visited do
			xy=next_point(top.x,top.y)
			idx=idx_xy(xy.x,xy.y)
		end
		
		if xy.x>top.x then
			grid[idx]=east_path
		elseif xy.x<top.x then
			grid[idx]=west_path
		end
		
		if xy.y>top.y then
			grid[idx]=south_path
		elseif xy.y<top.y then
			grid[idx]=north_path
		end
		
		visited_count+=1
		
		local t=stack()
		t.x=xy.x
		t.y=xy.y
		t.n=top
		top=t
	else
		while not has_not_visited_neighbors() and top.n!=nil do
			top=top.n
		end
	end
end

function _update60()
	if visited_count <= (cols*rows) then
		advance_point()
	else
		done=true
	end
	if btnp(❎) then
		_init()
	end	
end

function _draw()
	cls()
	for i=0,cols-1 do
		for j=0,rows-1 do
			local idx=idx_xy(i,j)
			local r={
				x=i*size-1,
				y=j*size-1,
				w=size-2,
				h=size-2,
			}
			local wall={x=0,y=0,w=0,h=0}
			local c=12
			if grid[idx]==east_path then
				c=7
				wall.x=r.x-2
				wall.y=r.y
				wall.w=2
				wall.h=r.h
			end
			if grid[idx]==west_path then
				c=7
				wall.x=r.x+r.w
				wall.y=r.y
				wall.w=2
				wall.h=r.h
			end
			if grid[idx]==south_path then
				c=7
				wall.x=r.x
				wall.y=r.y-2
				wall.w=r.w
				wall.h=2
			end
			if grid[idx]==north_path then
				c=7
				wall.x=r.x
				wall.y=r.y+r.h
				wall.w=r.w
				wall.h=2
			end
			
			if idx==0 then
				c=6
			end
			
			if idx==(cols*rows)-1 then
				c=11
			end
			
			if idx!=0 then
				rectfill(
					1+wall.x,
					1+wall.y,
					1+wall.x+wall.w,
					1+wall.y+wall.h,
					7)
			end
			
			rectfill(
				1+r.x,
				1+r.y,
				1+r.x+r.w,
				1+r.y+r.h,
				c)
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
