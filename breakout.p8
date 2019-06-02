pico-8 cartridge // http://www.pico-8.com
version 16
__lua__


function _init()
	cls()
--game mode
mode="start"

end

function _update60()
if mode =="game" then
		update_game()	
	elseif mode =="start" then
		update_start()
	elseif mode=="gameover" then
		update_gameover()
	end
end

function startgame()
	mode="game"
		
	lifes=1
	points=0
	
	--paddle variables
	pad_x=30
	pad_y=120
	pad_dx=1.5
	pad_w=30
	pad_h=4
	pad_c=7
	
	--brick variables
	brick_w=9
	brick_h=4
	buildbricks()
	
	serveball()
end

function serveball()
		--ball variables
	ball_x=50
	ball_y=30
	ball_dx=1
	ball_dy=1
	ball_r=2
end

function buildbricks()
	local i
	brick_x={}
	brick_y={}
	brick_v={}

	for i=1,22 do
		add(brick_x,4+((i-1)%11)*(brick_w+2))
		add(brick_y,20+flr(i/12)*(brick_h+2))
		add(brick_v,true)
	end
end

function update_start()
	if btn(❎) then
		startgame()
	end
end

function update_game()
	local buttpress=false
	local nextx,nexty
	if btn(⬅️) then
		pad_dx=-2.5
		buttpress=true
	end
	
	if btn(➡️) then
		pad_dx=2.5
		buttpress=true
	end
	
	if not(buttpress) then
		pad_dx=pad_dx/1.4
	end
	pad_x+=pad_dx
	pad_x=mid(0,pad_x,127-pad_w)

	nextx=ball_x+ball_dx
	nexty=ball_y+ball_dy
	
	if nextx > 124 or nextx < 3 then
		nextx=mid(0,nextx,124)
		ball_dx= -ball_dx
		sfx(0)
	end
	
	if nexty < 10 then
		nexty=mid(0,nexty,124)
		ball_dy = -ball_dy
		sfx(0)
	end
	
	 --check if ball hits pad
	if ball_box(nextx,nexty,pad_x,pad_y,pad_w,pad_h) then
		--deal with collision
		--find out direction to deflect
		if deflx_ball_box(ball_x,ball_y,ball_dx,ball_dy,pad_x,pad_y,pad_w,pad_h) then
			ball_dx = -ball_dx
		else
			ball_dy = -ball_dy
		end
		points+=1
		sfx(1)
	end
	
	for i=1,#brick_x do
	 --check if ball hits brick
		if brick_v[i] and ball_box(nextx,nexty,brick_x[i],brick_y[i],brick_w,brick_h) then
		--deal with collision
		--find out direction to deflect
			if deflx_ball_box(ball_x,ball_y,ball_dx,ball_dy,brick_x[i],brick_y[i],brick_w,brick_h) then
				ball_dx = -ball_dx
			else
				ball_dy = -ball_dy
			end
			points+=10
			brick_v[i]=false
			sfx(3)
		end
	end
	
	ball_x=nextx
	ball_y=nexty
	
	if nexty >124 then
		sfx(2)
		lifes-=1
		if lifes < 0 then
			gameover()
		else
		serveball()
		end
	end
	
end

function gameover()
	mode="gameover"
end

function update_gameover()
	if btn(❎) then
		startgame()
	end
end

function _draw()
	if mode =="game" then
		draw_game()	
	elseif mode =="start" then
		draw_start()
	elseif mode=="gameover" then
		draw_gameover()
	end
end

function draw_start()
	cls()
	print("achiri breakout",36,40,7)
	print("press ❎ to start",32,80,11)
end

function draw_game()
	local i
	cls(1)
	circfill(ball_x,ball_y,ball_r,10)
	rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,pad_c)
	
	--draw bricks
	
	for i=1,#brick_x do
		if brick_v[i] then
			rectfill(brick_x[i],brick_y[i],brick_x[i]+brick_w,brick_y[i]+brick_h,14)
		end	
	end
	
	--
	
	rectfill(0,0,128,6,0)
	print("lifes: "..lifes,0,0,7)
	print("points: "..points,40,0,7)
end

function draw_gameover()
	rectfill(0,60,128,74,0)
	print("game over",46,62,7)
	print("press ❎ to restart",27,68,7)
end

---------- collision -----------

function ball_box(bx,by,box_x,box_y,box_w,box_h)
	--chechs for a col of the box with the ball
	if by-ball_r > box_y+box_h then
		return false
	end
	if by+ball_r < box_y then
		return false
	end
	if bx-ball_r > box_x+box_w then
		return false
	end
	if bx+ball_r < box_x then
		return false
	end
		
	return true
end

function deflx_ball_box(bx,by,bdx,bdy,tx,ty,tw,th)
 local slp = bdy / bdx
 local cx, cy
 
 if bdx == 0 then
        return false
 elseif bdy == 0 then
  return true
 elseif slp > 0 and bdx > 0 then
  cx = tx - bx
  cy = ty - by
  return cx > 0 and cy/cx < slp
 elseif slp < 0 and bdx > 0 then
  cx = tx - bx
  cy = ty + th - by
  return cx > 0 and cy/cx >= slp
 elseif slp > 0 and bdx < 0 then
  cx = tx + tw - bx
  cy = ty + th - by
  return cx < 0 and cy/cx <= slp
 else
  cx = tx + tw - bx
  cy = ty - by
  return cx < 0 and cy/cx >= slp
 end
end

--------------------------------
__sfx__
000100001837018330183301832018310213100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002437024330243302432024310243100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000181501515013130111300f1300d1300a1200812005120031200111001100011001d50021500015002450027500285002a50028500235001a500095000950000000000000000000000000000000000000
000300002615024120211101f11004600016000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000001f10000000000000000000000
