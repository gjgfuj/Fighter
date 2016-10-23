local rect = require "rect"
local char = require "char"
local standing = require "standing"
local inputHandler = require "inputHandler"
local fireball = require "fireball"
local attack = require "attack"
local crouching = require "crouching"
local jumping = require "jumping"
local sliding = require "sliding"
local hitstun = require "hitstun"
local knockup = require "knockup"
local knockdown = require "knockdown"
local jumpingAttack = require "jumpingAttack"
local throw = require "throw"
local throwing = require "throwing"
local thrown = require "thrown"

--Characters
local c1
local c2
local fps = 0--Holds the current fps for the fps display
local image--Holds the Brett sprite for testing
local canvas--Canvas to draw the game world before scaling it

function love.run()
 
	if love.math then
		love.math.setRandomSeed(os.time())
	end
 
	if love.load then love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
	local accumulator = 0.0
	local lastFrame = 0
	-- Main loop time.
	while true do
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
		accumulator = accumulator + dt
		if(accumulator >= 1/60) then
			accumulator = accumulator - 1/60
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
			
			-- Call update and draw
			if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
	 
			if love.graphics and love.graphics.isActive() then
				love.graphics.clear(love.graphics.getBackgroundColor())
				love.graphics.setCanvas(canvas)
				love.graphics.clear(love.graphics.getBackgroundColor())
				love.graphics.setCanvas()
				love.graphics.origin()
				if love.draw then love.draw() end
				love.graphics.present()
			end
			fps = 1/(love.timer.getTime()-lastFrame)
			lastFrame = love.timer.getTime()
		end
	end
end

local function makeTestChar(toMake,opponent)
	toMake.image = image
	local forwardMedium = attack(toMake,opponent,10,5,20,{{54,30,42,19}},33,10,hitstun(opponent,toMake,60,33),hitstun(opponent,toMake,30,33))--pass hitboxes differently, e.g only coordinates for the attack to construct them in update
	forwardMedium.inStartup = function (self) local vel = 6 if not self.c1.lookingRight then vel = -vel end   self.c1:move(vel,0,self.c2) end
	forwardMedium.inRecovery = function (self) local vel = -3 if not self.c1.lookingRight then vel = -vel end  self.c1:move(vel,0,self.c2)end
	local fireballAttack = attack(toMake,opponent,15,1,0,{})
	fireballAttack.beforeCollisionCheck = function(self) local vel = 250 if not self.c1.lookingRight then vel = -vel end table.insert(entities,fireball(self.c2,self.c1.x,self.c1.y+150,50,50,vel, toMake)) end
	local mediumPunch = attack(toMake,opponent,5,3,10,{{54,30,42,19}},100,10,hitstun(opponent,toMake,60,33),hitstun(opponent,toMake,30,33))
	local heavyPunch = attack(toMake,opponent,8,5,1,{{54,0,42,49}},100,10,knockup(opponent,toMake,4.5,-7),hitstun(opponent,toMake,30,500))
	heavyPunch.effect.fallbackState = knockdown(opponent,toMake,30)
	heavyPunch.effect.overwriteVel = true
	
	local throw = throw(toMake,opponent,6,10,15,{{54,30,10,105}},0,thrown(opponent,toMake,60,240,0),throwing(toMake,opponent,45))

	mediumPunch.onFrame[9] = function (self) 
		added = rect(54+self.c1.x,30+self.c1.y,42,19)  
		if not self.c1.lookingRight then 
			flipBox(added,self.c1.width,self.c1) 
		end 
		table.insert(self.hurtboxes,added)
	end
	mediumPunch:addHurtbox(20,1,27,29)
	mediumPunch:addHurtbox(5,30,49,21)
	mediumPunch:addHurtbox(2,52,55,15,{"throwable"})
	mediumPunch:addHurtbox(0,78,56,14)
	mediumPunch:addHurtbox(1,92,60,8)
	mediumPunch:addHurtbox(2,100,62,8)
	mediumPunch:addHurtbox(12,109,53,12)
	mediumPunch:addHurtbox(13,121,50,3)
	mediumPunch:addHurtbox(8,124,58,11)
	mediumPunch:addCollisionbox(5,30,52,105)
	mediumPunch:addCollisionbox(20,1,27,29)
	
	
	heavyPunch:addHurtbox(20,1,27,29)
	heavyPunch:addHurtbox(5,30,49,21)
	heavyPunch:addHurtbox(2,52,55,15,{"throwable"})
	heavyPunch:addHurtbox(0,78,56,14)
	heavyPunch:addHurtbox(1,92,60,8)
	heavyPunch:addHurtbox(2,100,62,8)
	heavyPunch:addHurtbox(12,109,53,12)
	heavyPunch:addHurtbox(13,121,50,3)
	heavyPunch:addHurtbox(8,124,58,11)
	heavyPunch:addCollisionbox(5,30,52,105)
	heavyPunch:addCollisionbox(20,1,27,29)
	
	forwardMedium:addHurtbox(20,1,27,29)
	forwardMedium:addHurtbox(5,30,49,21)
	forwardMedium:addHurtbox(2,52,55,15,{"throwable"})
	forwardMedium:addHurtbox(0,78,56,14)
	forwardMedium:addHurtbox(1,92,60,8)
	forwardMedium:addHurtbox(2,100,62,8)
	forwardMedium:addHurtbox(12,109,53,12)
	forwardMedium:addHurtbox(13,121,50,3)
	forwardMedium:addHurtbox(8,124,58,11)
	forwardMedium:addCollisionbox(5,30,52,105)
	forwardMedium:addCollisionbox(20,1,27,29)

	fireballAttack:addHurtbox(20,1,27,29)
	fireballAttack:addHurtbox(5,30,49,21)
	fireballAttack:addHurtbox(2,52,55,15,{"throwable"})
	fireballAttack:addHurtbox(0,78,56,14)
	fireballAttack:addHurtbox(1,92,60,8)
	fireballAttack:addHurtbox(2,100,62,8)
	fireballAttack:addHurtbox(12,109,53,12)
	fireballAttack:addHurtbox(13,121,50,3)
	fireballAttack:addHurtbox(8,124,58,11)
	fireballAttack:addCollisionbox(5,30,52,105)
	fireballAttack:addCollisionbox(20,1,27,29)
	
	local standingState = standing(toMake,opponent,{['LP'] = slide, ['MP'] = mediumPunch, ["HP"] = heavyPunch,["HK"] = forwardMedium},{['MP,r'] = forwardMedium},{['LP,LK'] = throw},{["MP,r,rd,d"] = fireballAttack})
	standingState:addHurtbox(20,1,27,29)
	standingState:addHurtbox(5,30,49,21)
	standingState:addHurtbox(2,52,55,15,{"throwable"})
	standingState:addHurtbox(0,78,56,14)
	standingState:addHurtbox(1,92,60,8)
	standingState:addHurtbox(2,100,62,8)
	standingState:addHurtbox(12,109,53,12)
	standingState:addHurtbox(13,121,50,3)
	standingState:addHurtbox(8,124,58,11)
	standingState:addHurtbox(54,30,18,19)
	standingState:addHurtbox(58,20,13,10)
	standingState:addHurtbox(60,7,14,12)
	standingState:addCollisionbox(5,30,52,105)
	standingState:addCollisionbox(20,1,27,29)
	toMake:setstanding(standingState)
	
	crouchingMP = attack(toMake,opponent,5,3,10,{{65,80,42,19}})
	crouchingMP:addHurtbox(22,49,27,29)
	crouchingMP:addHurtbox(0,100,65,35)
	crouchingMP:addHurtbox(0,78,60,21)
	crouchingMP:addCollisionbox(22,49,28,29)
	crouchingMP:addCollisionbox(0,79,65,56)
	
	local crouchingState = crouching(toMake,opponent,{MP = crouchingMP},{},{},{})
	crouchingState:addHurtbox(22,49,27,29)
	crouchingState:addHurtbox(0,100,65,35)
	crouchingState:addHurtbox(0,78,60,21)
	crouchingState:addCollisionbox(22,49,28,29)
	crouchingState:addCollisionbox(0,79,65,56)
	toMake:setCrouching(crouchingState)
	
	local jumpingMP = jumpingAttack(toMake,opponent,0,0,10,6,20,{{54,30,42,19}},100,10,hitstun(opponent,toMake,60,133),hitstun(opponent,toMake,10,133))
	jumpingMP:addHurtbox(20,1,27,29)
	jumpingMP:addHurtbox(5,30,49,21)
	jumpingMP:addHurtbox(2,52,55,15,{"throwable"})
	jumpingMP:addHurtbox(0,78,56,14)
	jumpingMP:addHurtbox(1,92,60,8)
	jumpingMP:addHurtbox(2,100,62,8)
	jumpingMP:addHurtbox(12,109,53,12)
	jumpingMP:addHurtbox(13,121,50,3)
	jumpingMP:addHurtbox(8,124,58,11)
	jumpingMP:addCollisionbox(5,30,52,105)
	jumpingMP:addCollisionbox(20,1,27,29)

	local jumpingState = jumping(toMake,opponent,0,-10,{MP=jumpingMP},{},{},{})
	jumpingState:addHurtbox(20,1,26,29)
	jumpingState:addHurtbox(5,30,49,21)
	jumpingState:addHurtbox(2,52,55,15,{"throwable"})
	jumpingState:addHurtbox(0,78,56,14)
	jumpingState:addHurtbox(1,92,60,8)
	jumpingState:addHurtbox(2,100,62,8)
	jumpingState:addHurtbox(12,109,53,12)
	jumpingState:addHurtbox(13,121,50,3)
	jumpingState:addHurtbox(8,124,58,11)
	jumpingState:addHurtbox(54,30,18,19)
	jumpingState:addHurtbox(58,20,13,10)
	jumpingState:addHurtbox(60,7,14,12)
	jumpingState:addCollisionbox(5,30,52,105)
	jumpingState:addCollisionbox(20,1,27,29)
	toMake:setJumping(jumpingState)
	
	local jumpingForward = jumping(toMake,opponent,3,-10,{MP=jumpingMP},{},{},{})
	jumpingForward:addHurtbox(22,49,27,29)
	jumpingForward:addHurtbox(0,100,65,35)
	jumpingForward:addHurtbox(0,78,60,21)
	jumpingForward:addCollisionbox(22,49,28,29)
	jumpingForward:addCollisionbox(0,79,65,56)
	toMake:setJumpForward(jumpingForward)
	
	local jumpingBack = jumping(toMake,opponent,-3,-10,{MP=jumpingMP},{},{},{})
	jumpingBack:addHurtbox(22,49,27,29)
	jumpingBack:addHurtbox(0,100,65,35)
	jumpingBack:addHurtbox(0,78,60,21)
	jumpingBack:addCollisionbox(22,49,28,29)
	jumpingBack:addCollisionbox(0,79,65,56)
	toMake:setJumpBack(jumpingBack)
	
	toMake:setKnockupBoxes({{-((toMake:getBottom()-toMake.y)-image:getWidth()),(toMake:getBottom()-toMake.y-33),(toMake:getBottom()-toMake.y),33}},{{-((toMake:getBottom()-toMake.y)-image:getWidth()),toMake:getBottom()-toMake.y-33,toMake:getBottom()-toMake.y,33}})
end

function love.load()
	love.graphics.setDefaultFilter("nearest","nearest",1)
	image = love.graphics.newImage("Images/Brett.png")
 	canvas = love.graphics.newCanvas(640,360)
	love.window.setMode(640,360,{["fullscreen"] = true,["fullscreentype"]= "desktop", ["vsync"] = true})
	local image = love.graphics.newImage("Images/Brett.png")
	local speed = 167
	
	entities = {}
	
	local mapping = {l = 'l',r = 'r',d = 'd', u = 'u', rd = "rd",ru = "ru", ld = "ld", lu = "lu", a = "LK", b = "MK", triggerright = "HK", x = "LP", y = "MP", rightshoulder = "HP"}
	local mapping2 = {a = 'l' ,d = 'r',w = 'u',s = 'd', f = 'LP', g = 'MP',h= 'HP', c = 'LK', v = 'MK', b = 'HK'}
	local handler = inputHandler(love.joystick.getJoysticks()[1],mapping)
	local handler2 = inputHandler("keyboard",mapping2)
	
	
	c1 = char(179,198,handler2)
	c2 = char(322,198,handler)
	
	makeTestChar(c1,c2)
	makeTestChar(c2,c1)
	
	love.graphics.setBackgroundColor(0,53,255)
end

function love.draw()
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(0,38,153)
	love.graphics.rectangle("fill",0,300,640,60)
	love.graphics.setColor(255,255,255)
	c1:draw()
	c2:draw()
	for k,v in ipairs(entities) do
		v:draw()
	end
	love.graphics.setCanvas()
	love.graphics.push()
--	love.graphics.scale(2)
	love.graphics.setColor(255,255,255)
	local width,height = love.graphics.getDimensions()
	love.graphics.draw(canvas,0,0,0,width/640,height/360)
	love.graphics.pop()
	love.graphics.print("FPS:"..fps,0,0)
	love.graphics.print("c1 - x:"..c1.x.." y:"..c1.y,300,0)
	love.graphics.print("c2 - x:"..c2.x.." y:"..c2.y,700,0)
end

local i = 0
function love.update(dt)
	--update both characters
	c1:update(c2)
	c2:update(c1)
	--update other entities,such as fireballs	
	for k,v in ipairs(entities) do
		if v.update then v:update() end
	end
	--assign the states which may have been queued during this frame	
	if c1.nextState then
		c1:setState(c1.nextState)
		c1.nextState = nil
	end
	
	if c2.nextState then
		c2:setState(c2.nextState)
		c2.nextState = nil
	end
	i = i+1
end
