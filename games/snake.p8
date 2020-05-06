pico-8 cartridge // http://www.pico-8.com
version 23
__lua__
-- SNAKE
-- BY ADAM RICHARDSON

function _init()
	size=4
	cols =128/size
	snake_v=1
	pill_v=2
	dir_n=1
	dir_s=2
	dir_e=3
	dir_w=4
	starting_len=3
	grid={}
	update_ticks=10
	ticks=0
	score=0
	head=snake_cell()
	is_gameover=false
	next_dir=0
	pill_idx=0
	for i=1,(cols*cols) do
		add(grid,0)
	end
	setup()
end

function snake_cell()
	return {
		x=0,
		y=0,
		n=nil,
		d=0,
	}
end

function idx_xy(x,y)
	return x+(y*cols)
end

function setup()
	for i=1,(cols*cols) do
		grid[i]=0
	end
	next_dir=dir_e
	head.x=flr(rnd(cols/2))+starting_len
	head.y=flr(rnd(cols/2))+starting_len
	head.d=next_dir
	head.n=nil
	for i=1,starting_len do
		grow_snake()
	end
	
	local cell=head
	while cell do
		grid[idx_xy(cell.x,cell.y)]=snake_v
		cell=cell.n
	end
	
	new_pill()
	
	is_gameover=false
	ticks=0
	score=0
end

function grow_snake()
	local cell=head
	while cell.n do
		cell=cell.n
	end
	
	local grow=snake_cell()
	grow.x=cell.x
	grow.y=cell.y
	grow.n=nil
	grow.d=cell.d
	cell.n=grow
	local growpos={
		{x=grow.x,y=grow.y+1},
		{x=grow.x,y=grow.y-1},
		{x=grow.x-1,y=grow.y},
		{x=grow.x+1,y=grow.y}
	}
	local xy=growpos[grow.d]
	grow.x=xy.x
	grow.y=xy.y
end

function new_pill()
	local check_grid={}
	local ncheck=0
	for i=1,(cols*cols) do
		if grid[i] != snake_v then
			add(check_grid,i)
			ncheck += 1
		end
	end
	local idx=flr(rnd(ncheck))
	pill_idx=check_grid[idx]
	grid[pill_idx] = pill_v	
end

function gameover()
	is_gameover=true
end

function handle_input(d)
	local new_dir=d
	if btnp(⬅️) then
		if d!=dir_e and d!=dir_w then
			new_dir=dir_w
		end
	end
	
	if btnp(➡️) then
		if d!=dir_e and d!=dir_w then
			new_dir=dir_e
		end
	end
	
	if btnp(⬆️) then
		if d!=dir_n and d!=dir_s then
			new_dir=dir_n
		end
	end
	
	if btnp(⬇️) then
		if d!=dir_n and d!=dir_s then
			new_dir=dir_s
		end
	end
	return new_dir
end

function should_wait()
	ticks+=1
	if ticks!=update_ticks then
		return true
	end
	ticks=0
	
	return false
end

function _update60()
	if is_gameover then
		if btn(❎) then
			setup()
		end
		return
	end
	
	next_dir = handle_input(next_dir)
	if should_wait() then
		return
	end
	
	local cell=head
	local d=next_dir
	while cell do
		grid[idx_xy(cell.x,cell.y)]=0
		local last_dir=cell.d
		local cellpos={
			{x=cell.x,y=cell.y-1},
			{x=cell.x,y=cell.y+1},
			{x=cell.x+1,y=cell.y},
			{x=cell.x-1,y=cell.y},
		}
		local xy=cellpos[d]
		cell.x=xy.x
		cell.y=xy.y
		cell.d=d
		if cell.x > cols or cell.x < 0 or
				cell.y > cols or cell.y < 0 then
			gameover()
			return
		end
		
		if grid[idx_xy(cell.x,cell.y)] == snake_v then
			gameover()
			return
		end
		
		grid[idx_xy(cell.x,cell.y)]=snake_v
		cell=cell.n
		d=last_dir
	end
	
	if idx_xy(head.x,head.y) == pill_idx then
		new_pill()
		grow_snake()
		-- play sound
		score += 1
	end
end

function _draw()
	cls(3)
	for i=0,cols-1 do
		for j=0,cols-1 do
			local v=grid[idx_xy(i,j)]
			if v==snake_v then
				local c=1
				if i==head.x and j==head.y then
					c=11
				end
				rectfill(
					i*size,
					j*size,
					i*size+size-1,
					j*size+size-1,
					c)
			elseif v==pill_v then
				rectfill(
					i*size,
					j*size,
					i*size+size-1,
					j*size+size-1,
					8)
			end
		end
	end
	
	print(score,7)
	if is_gameover then
		print("game over",7)
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
