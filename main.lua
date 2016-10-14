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

local c1
local c2
local fps = 0
local image

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
	local forwardMedium = attack(toMake,opponent,10,5,20,{{162,90,127,57}},100,10,hitstun(opponent,toMake,60,100),hitstun(opponent,toMake,30,100))--pass hitboxes differently, e.g only coordinates for the attack to construct them in update
	forwardMedium.inStartup = function (self) local vel = 20 if not self.c1.lookingRight then vel = -vel end   self.c1:move(vel,0,self.c2) end
	forwardMedium.inRecovery = function (self) local vel = -10 if not self.c1.lookingRight then vel = -vel end  self.c1:move(vel,0,self.c2)end
	local fireballAttack = attack(toMake,opponent,15,1,0,{})
	fireballAttack.beforeCollisionCheck = function(self) local vel = 750 if not self.c1.lookingRight then vel = -vel end table.insert(entities,fireball(self.c2,self.c1.x,self.c1.y+150,50,50,vel, toMake)) end
	local mediumPunch = attack(toMake,opponent,5,3,10,{{162,90,127,57}},100,10,hitstun(opponent,toMake,60,100),hitstun(opponent,toMake,30,100))
	local heavyPunch = attack(toMake,opponent,8,5,1,{{162,0,127,147}},100,10,knockup(opponent,toMake,500,-1750),hitstun(opponent,toMake,30,500))
	heavyPunch.effect.fallbackState = knockdown(opponent,toMake,300)
	
	mediumPunch.onFrame[9] = function (self) 
		added = rect(162+self.c1.x,90+self.c1.y,127,57)  
		if not self.c1.lookingRight then 
			flipBox(added,self.c1.width,self.c1) 
		end 
		table.insert(self.hurtboxes,added)
	end
	
	mediumPunch:addHurtbox(60,2,80,88)
	mediumPunch:addHurtbox(14,91,147,65)
	mediumPunch:addHurtbox(6,157,165,75)
	mediumPunch:addHurtbox(0,233,170,44)
	mediumPunch:addHurtbox(4,277,181,24)
	mediumPunch:addHurtbox(5,302,185,24)
	mediumPunch:addHurtbox(35,327,160,35)
	mediumPunch:addHurtbox(40,363,150,8)
	mediumPunch:addHurtbox(25,372,175,33)
	mediumPunch:addCollisionbox(14,90,157,315)
	mediumPunch:addCollisionbox(60,2,80,88)
	
	heavyPunch:addHurtbox(60,2,80,88)
	heavyPunch:addHurtbox(14,91,147,65)
	heavyPunch:addHurtbox(6,157,165,75)
	heavyPunch:addHurtbox(0,233,170,44)
	heavyPunch:addHurtbox(4,277,181,24)
	heavyPunch:addHurtbox(5,302,185,24)
	heavyPunch:addHurtbox(35,327,160,35)
	heavyPunch:addHurtbox(40,363,150,8)
	heavyPunch:addHurtbox(25,372,175,33)
	heavyPunch:addCollisionbox(14,90,157,315)
	heavyPunch:addCollisionbox(60,2,80,88)
	
	forwardMedium:addHurtbox(60,2,80,88)
	forwardMedium:addHurtbox(14,91,147,65)
	forwardMedium:addHurtbox(6,157,165,75)
	forwardMedium:addHurtbox(0,233,170,44)
	forwardMedium:addHurtbox(4,277,181,24)
	forwardMedium:addHurtbox(5,302,185,24)
	forwardMedium:addHurtbox(35,327,160,35)
	forwardMedium:addHurtbox(40,363,150,8)
	forwardMedium:addHurtbox(25,372,175,33)
	forwardMedium:addCollisionbox(14,90,157,315)
	forwardMedium:addCollisionbox(60,2,80,88)
	
	fireballAttack:addHurtbox(60,2,80,88)
	fireballAttack:addHurtbox(14,91,147,65)
	fireballAttack:addHurtbox(6,157,165,75)
	fireballAttack:addHurtbox(0,233,170,44)
	fireballAttack:addHurtbox(4,277,181,24)
	fireballAttack:addHurtbox(5,302,185,24)
	fireballAttack:addHurtbox(35,327,160,35)
	fireballAttack:addHurtbox(40,363,150,8)
	fireballAttack:addHurtbox(25,372,175,33)
	fireballAttack:addHurtbox(162,90,53,57)
	fireballAttack:addHurtbox(175,60,39,29)
	fireballAttack:addHurtbox(180,22,44,37)
	fireballAttack:addCollisionbox(14,90,157,315)
	fireballAttack:addCollisionbox(60,2,80,88)
	
	local standingState = standing(toMake,opponent,{['LP'] = slide, ['MP'] = mediumPunch, ["HP"] = heavyPunch},{['MP,r'] = forwardMedium},{},{["MP,r,rd,d"] = fireballAttack})
	standingState:addHurtbox(60,2,80,88)
	standingState:addHurtbox(14,91,147,65)
	standingState:addHurtbox(6,157,165,75)
	standingState:addHurtbox(0,233,170,44)
	standingState:addHurtbox(4,277,181,24)
	standingState:addHurtbox(5,302,185,24)
	standingState:addHurtbox(35,327,160,35)
	standingState:addHurtbox(40,363,150,8)
	standingState:addHurtbox(25,372,175,33)
	standingState:addHurtbox(162,90,53,57)
	standingState:addHurtbox(175,60,39,29)
	standingState:addHurtbox(180,22,44,37)
	standingState:addCollisionbox(14,90,157,315)
	standingState:addCollisionbox(60,2,80,88)
	toMake:setstanding(standingState)
	
	crouchingMP = attack(toMake,opponent,5,3,10,{{181,240,127,57}})
	crouchingMP:addHurtbox(65,148,80,88)
	crouchingMP:addHurtbox(0,301,194,104)
	crouchingMP:addHurtbox(0,236,180,64)
	crouchingMP:addCollisionbox(65,148,80,88)
	crouchingMP:addCollisionbox(0,236,194,169)
	
	local crouchingState = crouching(toMake,opponent,{MP = crouchingMP},{},{},{})
	crouchingState:addHurtbox(65,148,80,88)
	crouchingState:addHurtbox(0,301,194,104)
	crouchingState:addHurtbox(0,236,180,64)
	crouchingState:addCollisionbox(65,148,80,88)
	crouchingState:addCollisionbox(0,236,194,169)
	toMake:setCrouching(crouchingState)

	local jumpingState = jumping(toMake,opponent,0,-1750,{},{},{},{})
	jumpingState:addHurtbox(60,2,80,88)
	jumpingState:addHurtbox(14,91,147,65)
	jumpingState:addHurtbox(6,157,165,75)
	jumpingState:addHurtbox(0,233,170,44)
	jumpingState:addHurtbox(4,277,181,24)
	jumpingState:addHurtbox(5,302,185,24)
	jumpingState:addHurtbox(35,327,160,35)
	jumpingState:addHurtbox(40,363,150,8)
	jumpingState:addHurtbox(25,372,175,33)
	jumpingState:addHurtbox(162,90,53,57)
	jumpingState:addHurtbox(175,60,39,29)
	jumpingState:addHurtbox(180,22,44,37)
	jumpingState:addCollisionbox(14,90,157,315)
	jumpingState:addCollisionbox(60,2,80,88)
	toMake:setJumping(jumpingState)
	
	local jumpingForward = jumping(toMake,opponent,750,-1750,{},{},{},{})
	jumpingForward:addHurtbox(65,148,80,88)
	jumpingForward:addHurtbox(0,301,194,104)
	jumpingForward:addHurtbox(0,236,180,64)
	jumpingForward:addCollisionbox(65,148,80,88)
	jumpingForward:addCollisionbox(0,236,194,169)
	toMake:setJumpForward(jumpingForward)
	
	local jumpingBack = jumping(toMake,opponent,-750,-1750,{},{},{},{})
	jumpingBack:addHurtbox(65,148,80,88)
	jumpingBack:addHurtbox(0,301,194,104)
	jumpingBack:addHurtbox(0,236,180,64)
	jumpingBack:addCollisionbox(65,148,80,88)
	jumpingBack:addCollisionbox(0,236,194,169)
	toMake:setJumpBack(jumpingBack)
	
	toMake:setKnockupBoxes({{0,(toMake:getBottom()-toMake.y-100),(toMake:getBottom()-toMake.y),100}},{{0,toMake:getBottom()-toMake.y-100,toMake:getBottom()-toMake.y,100}})
end

function love.load()
	image = love.graphics.newImage("Images/Brett.png")
	love.window.setMode(1920,1080,{["fullscreen"] = true,["fullscreentype"]= "desktop", ["vsync"] = true})
	local image = love.graphics.newImage("Images/Brett.png")
	local speed = 500
	
	entities = {}
	
	local mapping = {l = 'l',r = 'r',d = 'd', u = 'u', rd = "rd",ru = "ru", ld = "ld", lu = "lu", a = "LK", b = "MK", rt = "HK", x = "LP", y = "MP", rightshoulder = "HP"}
	local mapping2 = {a = 'l' ,d = 'r',w = 'u',s = 'd', f = 'LP', g = 'MP',h= 'HP', c = 'LK', v = 'MK', b = 'HK'}
	local handler = inputHandler(love.joystick.getJoysticks()[1],mapping)
	local handler2 = inputHandler("keyboard",mapping2)
	
	
	c1 = char(537,600,handler2)
	c2 = char(967,600,handler)
	
	makeTestChar(c1,c2)
	makeTestChar(c2,c1)
	
	love.graphics.setBackgroundColor(0,53,255)
end

function love.draw()
	love.graphics.setColor(0,38,153)
	love.graphics.rectangle("fill",0,900,1920,180)
	love.graphics.setColor(255,255,255)
	love.graphics.print("FPS:"..fps,0,0)
	c1:draw(500,"c1")
	c2:draw(1000,"c2")
	for k,v in ipairs(entities) do
		v:draw()
	end
end

function love.update(dt)
	c1:update(c2)
	c2:update(c1)
	
	for k,v in ipairs(entities) do
		if v.update then v:update() end
	end
	
	if c1.nextState then
		c1:setState(c1.nextState)
		c1.nextState = nil
	end
	
	if c2.nextState then
		c2:setState(c2.nextState)
		c2.nextState = nil
	end
end
