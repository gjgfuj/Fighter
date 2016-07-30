function love.load()
	rect = require "rect"
	char = require "char"
	
	love.window.setMode(1920,1080,{["fullscreen"] = true,["fullscreentype"]= "desktop", ["vsync"] = false})
	image = love.graphics.newImage("Images/Brett.png")
	speed = 500
	
	c1 = char(635,600)
	--hardcode hurtboxes here
	c1:addHurtbox(60,2,80,88)
	c1:addHurtbox(14,91,147,65)
	c1:addHurtbox(6,157,165,75)
	c1:addHurtbox(0,233,170,44)
	c1:addHurtbox(4,277,181,24)
	c1:addHurtbox(5,302,185,24)
	c1:addHurtbox(35,327,160,35)
	c1:addHurtbox(40,363,150,8)
	c1:addHurtbox(25,372,175,33)
	c1:addHurtbox(162,90,53,57)
	c1:addHurtbox(175,60,39,29)
	c1:addHurtbox(180,22,44,37)
	c1.image = image
	
	love.graphics.setBackgroundColor(0,53,255)
end

function love.draw()
    love.graphics.setColor(0,38,153)
	love.graphics.rectangle("fill",0,900,1920,180)
	love.graphics.setColor(255,255,255)
	love.graphics.print("FPS:"..love.timer.getFPS(),0,0)
	c1:draw();
end

function love.update(dt)
		if a_down and not d_down then c1:move(-speed*dt*0.75,0)  -- horizontal movement
		elseif d_down and not a_down then c1:move(speed*dt,0) end
		
		--if w_down and not s_down then c1:move(0,-speed*dt) -- vertical movement(disabled because that will be jumping)
		--elseif s_down and not w_down then c1:move(0,speed*dt) end
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