function love.load()
	rect = require "rect"
	char = require "char"
	
	speed = 500
	
	x = 20;
	y = 20;

	c1 = char()
	--hardcode hitboxes here
end

function love.draw()
	love.graphics.print("I love TOVG!",x,y);
	love.graphics.print(love.timer.getFPS(),0,0)
end

function love.update(dt)
		if a_down and not d_down then x = x-speed*dt  -- horizontal movement
		elseif d_down and not a_down then x= x+speed*dt end
		
		if w_down and not s_down then y = y-speed*dt -- vertical movement
		elseif s_down and not w_down then y = y+speed*dt end
		
		deltaTime = dt
end

function love.keypressed(key) 
	if key == 'a' then a_down = true  -- these booleans allow the update function
	elseif key == 'd' then d_down = true -- to see whether a key is currently held
	elseif key == 'w' then w_down = true
	elseif key == 's' then s_down = true end
	end
	
function love.keyreleased(key)
	if key == 'a' then a_down = false  -- just reset when they are released
	elseif key == 'd' then d_down = false
	elseif key == 'w' then w_down = false
	elseif key == 's' then s_down = false end
	end