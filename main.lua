function love.load()
	rect = require "rect"
	char = require "char"
	idle = require "idle"
	
	love.window.setMode(1920,1080,{["fullscreen"] = true,["fullscreentype"]= "desktop", ["vsync"] = true})
	image = love.graphics.newImage("Images/Brett.png")
	speed = 500
	
	dtTotal = 0
	
	inputs = {}
	
	c1 = char(537,600)
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
	c1:addCollisionbox(14,90,157,315)
	c1:addCollisionbox(60,2,80,88)
	c1.image = image
	
	c2 = char(967,600)
	--hardcode hurtboxes here
	c2:addHurtbox(60,2,80,88)
	c2:addHurtbox(14,91,147,65)
	c2:addHurtbox(6,157,165,75)
	c2:addHurtbox(0,233,170,44)
	c2:addHurtbox(4,277,181,24)
	c2:addHurtbox(5,302,185,24)
	c2:addHurtbox(35,327,160,35)
	c2:addHurtbox(40,363,150,8)
	c2:addHurtbox(25,372,175,33)
	c2:addHurtbox(162,90,53,57)
	c2:addHurtbox(175,60,39,29)
	c2:addHurtbox(180,22,44,37)
	c2:addCollisionbox(14,90,157,315)
	c2:addCollisionbox(60,2,80,88)
	c2.image = image
	
	c1.state = idle(c1,c2)
	
	love.graphics.setBackgroundColor(0,53,255)
end

function love.draw()
    love.graphics.setColor(0,38,153)
	love.graphics.rectangle("fill",0,900,1920,180)
	love.graphics.setColor(255,255,255)
	love.graphics.print("FPS:"..love.timer.getFPS(),0,0)
	love.graphics.print(image:getWidth(),200,0)	
	c1:draw(500,"c1")
	c2:draw(1000,"c2")
end

local function handleMovement(dt)

end

function love.update(dt)
    dtTotal = dtTotal+dt
	if(dtTotal >= 1/60) then
		dtTotal = 0
		
		c1.state:handleInput(inputs)
	
		if(c2.x < c1.x and c1.lookingRight or c2.x > c1.x and not c1.lookingRight) then c1:flip(image:getWidth()) -- make characters always face each other
		elseif (c1.x < c2.x and c2.lookingRight or c1.x > c2.x and not c2.lookingRight) then c2:flip(image:getWidth()) end
		
		--if w_down and not s_down then c1:move(0,-speed*dt) -- vertical movement(disabled because that will be jumping)
		--elseif s_down and not w_down then c1:move(0,speed*dt) end
	end
end

function love.keypressed(key) 
	inputs[key] = true
	end
	
function love.keyreleased(key)
	inputs[key] = false
	end