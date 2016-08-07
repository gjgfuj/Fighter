local rect = require "rect"
local char = require "char"
local standing = require "standing"
local inputHandler = require "inputHandler"
	
local c1
local c2

function love.run()
 
	if love.math then
		love.math.setRandomSeed(os.time())
	end
 
	if love.load then love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
 
	-- Main loop time.
	while true do
		local start_time = love.timer.getTime()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
		
		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end
		local end_time = love.timer.getTime()
		local frame_time = end_time - start_time
		
		if love.timer then love.timer.sleep(1/60-frame_time) end
	end
 
end

function love.load()
	love.window.setMode(1920,1080,{["fullscreen"] = true,["fullscreentype"]= "desktop", ["vsync"] = false})
	local image = love.graphics.newImage("Images/Brett.png")
	local speed = 500
	
	local mapping = {l = 'l',r = 'r',d = 'd', u = 'u', rd = "rd",ru = "ru", ld = "ld", lu = "lu", a = "LK", b = "MK", rt = "HK", x = "LP", y = "MP", rightshoulder = "HP"}
	local handler = inputHandler(love.joystick.getJoysticks()[1],mapping)
	
	
	c1 = char(537,600,handler)
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
	
	c2 = char(967,600,inputHandler("brot",{}))
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
	
	c1.state = standing(c1,c2)
	c2.state = standing(c2,c1)
	love.graphics.setBackgroundColor(0,53,255)
end

function love.draw()
	love.graphics.setColor(0,38,153)
	love.graphics.rectangle("fill",0,900,1920,180)
	love.graphics.setColor(255,255,255)
	love.graphics.print("FPS:"..love.timer.getFPS(),0,0)
	c1:draw(500,"c1")
	c2:draw(1000,"c2")
end


function love.update(dt)
	c1:handleInput(inputs)	
	c1:update()
	c2:update()
		
	if(c2.x < c1.x and c1.lookingRight or c2.x > c1.x and not c1.lookingRight) then c1:flip(226) -- make characters always face each other
	elseif (c1.x < c2.x and c2.lookingRight or c1.x > c2.x and not c2.lookingRight) then c2:flip(226) end
		
	if c1.nextState then
		c1.state = c1.nextState
		c1.nextState = nil
	end
	
	if c2.nextState then
		c2.state = c2.nextState
		c2.nextState = nil
	end
end

function love.keypressed(key)
	if(key=="rctrl") then debug.debug() end
end