pico-8 cartridge // http://www.pico-8.com
version 23
__lua__
basket_sprite=1

player_sprite=2
player_x=64
player_y=100

fruits={}
fruit_start=16
fruit_count=6
fruit_interval=16

gravity=1

level=1
points=0

function _init()
	for i=1,level do
		fruit={
			sprite=flr(rnd(fruit_count)+fruit_start),
			x=flr(rnd(120)+5),
			y=i*(-fruit_interval)
		}
		add(fruits,fruit)
	end
end

function _update()
	if btn(0) then 
		player_x-=2
		player_x=max(player_x,0)
	end
	if btn(1) then 
		player_x+=2
		player_x=min(player_x,119) 
	end
	
	for fruit in all(fruits) do
		fruit.y+=gravity
		
		if fruit.y+4>player_y-8
		and fruit.y+4<player_y
		and fruit.x+4>player_x
		and fruit.x+4<player_x+8 then
			points+=1
			del(fruits,fruit)
			sfx(0)
		end
		
		if fruit.y>100 then
			del(fruits,fruit)
		end
	end
	
	if #fruits==0 then
		level+=1
		_init()
	end
	
end

function _draw()
	cls(12)
	spr(6,90,20)
	rectfill(0,108,127,127,3)
	spr(player_sprite,player_x,player_y)
	spr(basket_sprite,player_x,player_y-8)
	
	for fruit in all(fruits) do
		spr(fruit.sprite,fruit.x,fruit.y)
	end
	
	for i=0,16 do
		spr(7,i*8,102)
	end
	
	print("score="..points,7)
end
__gfx__
0000000006666660f044440f000000000000000000000000a000000a000000000000000000000000000000000000000000000000000000000000000000000000
0000000070000006f0ffff0f0000000000000000000000000a0aa0a0000000000000000000000000000000000000000000000000000000000000000000000000
0070070067777775f0ffff0f00000000000000000000000000aaaa00000000000000000000000000000000000000000000000000000000000000000000000000
0007700066060605888ff8880000000000000000000000000aaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000
00077000606060d5008888000000000000000000000000000aaaaaa000b00b0b0000000000000000000000000000000000000000000000000000000000000000
0070070066060d0500cccc0000000000000000000000000000aaaa000bb0bb0b0000000000000000000000000000000000000000000000000000000000000000
0000000060d0d05500c00c000000000000000000000000000a0aa0a0bb0bb0bb0000000000000000000000000000000000000000000000000000000000000000
000000000555555009900990000000000000000000000000a000000ab00bb0b00000000000000000000000000000000000000000000000000000000000000000
000043b00000090000b0b0b00000b300000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bb03b00000a40000bbb00000b3300000008730099b30000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b7bb0000000a4000f9a900088338800000807b099b388000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b7bb000000a9400f9a9a4088e888880008887b97a9998800000000000000000000000000000000000000000000000000000000000000000000000000000000
0b7bbb30000a940009a9a4908e7e88820080807b9a99998800000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbbb300aa940000a9a494088e88882088887b39999998800000000000000000000000000000000000000000000000000000000000000000000000000000000
03bbbb300994000009a4949008888820b7777b300999988000000000000000000000000000000000000000000000000000000000000000000000000000000000
0033330000000000004949000222220003bbb3000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000e450314500e4502f4500f450104501045011450114502a4501d4501f4501f4501f4501e4500a4500a450374500c4500e4503545012450174501d4502245024450264502745026450254502545025450
