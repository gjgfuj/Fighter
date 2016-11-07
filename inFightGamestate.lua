local inFightGamestate = {}

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
local camera = require "camera"
local gui = require "gui"
local healthBar = require "healthBar"
local timer = require "timer"
require "eventSubject"

--Characters
local c1
local c2
local handler
local handler2
fps = 0--Holds the current fps for the fps display
local image--Holds the Brett sprite for testing
local canvas--Canvas to draw the game world before scaling it
local background = love.graphics.newCanvas(5200,360)
local playCamera
local activeGUI

local function makeTestChar(toMake,opponent)
	toMake.image = image
	local forwardMedium = attack(toMake,opponent,10,5,20,{{54,30,42,19}},33,10,hitstun(opponent,toMake,60,33),hitstun(opponent,toMake,30,33))--pass hitboxes differently, e.g only coordinates for the attack to construct them in update
	forwardMedium.inStartup = function (self) local vel = 6 if not self.c1.lookingRight then vel = -vel end   self.c1:move(vel,0,self.c2) end
	forwardMedium.inRecovery = function (self) local vel = -3 if not self.c1.lookingRight then vel = -vel end  self.c1:move(vel,0,self.c2)end
	local fireballAttack = attack(toMake,opponent,15,1,0,{})
	fireballAttack.beforeCollisionCheck = function(self) local vel = 250 if not self.c1.lookingRight then vel = -vel end table.insert(entities,fireball(self.c2,self.c1.x,self.c1.y+50,17,17,vel, toMake)) end
	local mediumPunch = attack(toMake,opponent,5,3,10,{{74,41,56,25}},100,10,hitstun(opponent,toMake,19,33),hitstun(opponent,toMake,14,33))
	local heavyPunch = attack(toMake,opponent,8,5,1,{{74,0,56,66}},100,10,knockup(opponent,toMake,6,-10),hitstun(opponent,toMake,30,500))
	heavyPunch.effect.fallbackState = knockdown(opponent,toMake,30)
	heavyPunch.effect.overwriteVel = true
	
	local throw = throw(toMake,opponent,6,10,15,{{74,41,13,137}},0,thrown(opponent,toMake,60,240,0),throwing(toMake,opponent,45))

	mediumPunch.onFrame[9] = function (self) 
		added = rect(74+self.c1.x,41+self.c1.y,56,25)  
		if not self.c1.lookingRight then 
			flipBox(added,self.c1.width,self.c1) 
		end 
		table.insert(self.hurtboxes,added)
	end
	mediumPunch:addHurtbox(27,0,36,40)
	mediumPunch:addHurtbox(7,41,66,29)
	mediumPunch:addHurtbox(3,71,74,21,{"throwable"})
	mediumPunch:addHurtbox(0,93,75,20)
	mediumPunch:addHurtbox(1,114,80,12)
	mediumPunch:addHurtbox(3,127,83,12)
	mediumPunch:addHurtbox(16,140,71,17)
	mediumPunch:addHurtbox(17,158,67,5)
	mediumPunch:addHurtbox(11,165,78,16)
	mediumPunch:addCollisionbox(7,40,70,141)
	mediumPunch:addCollisionbox(27,0,36,39)
	
	heavyPunch:addHurtbox(27,0,36,40)
	heavyPunch:addHurtbox(7,41,66,29)
	heavyPunch:addHurtbox(3,71,74,21,{"throwable"})
	heavyPunch:addHurtbox(0,93,75,20)
	heavyPunch:addHurtbox(1,114,80,12)
	heavyPunch:addHurtbox(3,127,83,12)
	heavyPunch:addHurtbox(16,140,71,17)
	heavyPunch:addHurtbox(17,158,67,5)
	heavyPunch:addHurtbox(11,165,78,16)
	heavyPunch:addCollisionbox(7,40,70,141)
	heavyPunch:addCollisionbox(27,0,36,39)

	forwardMedium:addHurtbox(27,0,36,40)
	forwardMedium:addHurtbox(7,41,66,29)
	forwardMedium:addHurtbox(3,71,74,21,{"throwable"})
	forwardMedium:addHurtbox(0,93,75,20)
	forwardMedium:addHurtbox(1,114,80,12)
	forwardMedium:addHurtbox(3,127,83,12)
	forwardMedium:addHurtbox(16,140,71,17)
	forwardMedium:addHurtbox(17,158,67,5)
	forwardMedium:addHurtbox(11,165,78,16)
	forwardMedium:addCollisionbox(7,40,70,141)
	forwardMedium:addCollisionbox(27,0,36,39)

	fireballAttack:addHurtbox(27,0,36,40)
	fireballAttack:addHurtbox(7,41,66,29)
	fireballAttack:addHurtbox(3,71,74,21,{"throwable"})
	fireballAttack:addHurtbox(0,93,75,20)
	fireballAttack:addHurtbox(1,114,80,12)
	fireballAttack:addHurtbox(3,127,83,12)
	fireballAttack:addHurtbox(16,140,71,17)
	fireballAttack:addHurtbox(17,158,67,5)
	fireballAttack:addHurtbox(11,165,78,16)
	fireballAttack:addCollisionbox(7,40,70,141)
	fireballAttack:addCollisionbox(27,0,36,39)
	
	local standingState = standing(toMake,opponent,{['LP'] = slide, ['MP'] = mediumPunch, ["HP"] = heavyPunch,["HK"] = forwardMedium},{['MP,f'] = forwardMedium},{['LP,LK'] = throw},{["MP,f,fd,d"] = fireballAttack})
	standingState:addHurtbox(27,0,36,40)
	standingState:addHurtbox(7,41,66,29)
	standingState:addHurtbox(3,71,74,21,{"throwable"})
	standingState:addHurtbox(0,93,75,20)
	standingState:addHurtbox(1,114,80,12)
	standingState:addHurtbox(3,127,83,12)
	standingState:addHurtbox(16,140,71,17)
	standingState:addHurtbox(17,158,67,5)
	standingState:addHurtbox(11,165,78,16)
	standingState:addCollisionbox(7,40,70,141)
	standingState:addCollisionbox(27,0,36,39)
	standingState:addHurtbox(74,41,24,25)
	standingState:addHurtbox(78,27,20,13)
	standingState:addHurtbox(80,7,19,19)
	toMake:setstanding(standingState)
	
	crouchingMP = attack(toMake,opponent,5,3,10,{{65,80,42,19}})
	crouchingMP:addHurtbox(29,66,38,39)
	crouchingMP:addHurtbox(0,134,87,47)
	crouchingMP:addHurtbox(0,105,80,28)
	crouchingMP:addCollisionbox(29,66,38,39)
	crouchingMP:addCollisionbox(0,106,87,75)
	
	local crouchingState = crouching(toMake,opponent,{MP = crouchingMP},{},{},{})
	crouchingState:addHurtbox(29,66,38,39)
	crouchingState:addHurtbox(0,134,87,47)
	crouchingState:addHurtbox(0,105,80,28)
	crouchingState:addCollisionbox(29,66,38,39)
	crouchingState:addCollisionbox(0,106,87,75)
	toMake:setCrouching(crouchingState)
	
	local jumpingMP = jumpingAttack(toMake,opponent,0,0,10,6,20,{{74,41,56,25}},100,10,hitstun(opponent,toMake,60,133),hitstun(opponent,toMake,10,133))
	jumpingMP:addHurtbox(27,0,36,40)
	jumpingMP:addHurtbox(7,41,66,29)
	jumpingMP:addHurtbox(3,71,74,21,{"throwable"})
	jumpingMP:addHurtbox(0,93,75,20)
	jumpingMP:addHurtbox(1,114,80,12)
	jumpingMP:addHurtbox(3,127,83,12)
	jumpingMP:addHurtbox(16,140,71,17)
	jumpingMP:addHurtbox(17,158,67,5)
	jumpingMP:addHurtbox(11,165,78,16)
	jumpingMP:addCollisionbox(7,40,70,141)
	jumpingMP:addCollisionbox(27,0,36,39)

	local jumpingState = jumping(toMake,opponent,0,-10,{MP=jumpingMP},{},{},{})
	jumpingState:addHurtbox(27,0,36,40)
	jumpingState:addHurtbox(7,41,66,29)
	jumpingState:addHurtbox(3,71,74,21,{"throwable"})
	jumpingState:addHurtbox(0,93,75,20)
	jumpingState:addHurtbox(1,114,80,12)
	jumpingState:addHurtbox(3,127,83,12)
	jumpingState:addHurtbox(16,140,71,17)
	jumpingState:addHurtbox(17,158,67,5)
	jumpingState:addHurtbox(11,165,78,16)
	jumpingState:addCollisionbox(7,40,70,141)
	jumpingState:addCollisionbox(27,0,36,39)
	jumpingState:addHurtbox(74,41,24,25)
	jumpingState:addHurtbox(78,27,20,13)
	jumpingState:addHurtbox(80,7,19,19)
	toMake:setJumping(jumpingState)
	
	local jumpingForward = jumping(toMake,opponent,3,-10,{MP=jumpingMP},{},{},{})
	jumpingForward:addHurtbox(29,66,38,39)
	jumpingForward:addHurtbox(0,134,87,47)
	jumpingForward:addHurtbox(0,105,80,28)
	jumpingForward:addCollisionbox(29,66,38,39)
	jumpingForward:addCollisionbox(0,106,87,75)
	toMake:setJumpForward(jumpingForward)
	
	local jumpingBack = jumping(toMake,opponent,-3,-10,{MP=jumpingMP},{},{},{})
	jumpingBack:addHurtbox(29,66,38,39)
	jumpingBack:addHurtbox(0,134,87,47)
	jumpingBack:addHurtbox(0,105,80,28)
	jumpingBack:addCollisionbox(29,66,38,39)
	jumpingBack:addCollisionbox(0,106,87,75)
	toMake:setJumpBack(jumpingBack)
	
	toMake:setKnockupBoxes({{-((toMake:getBottom()-toMake.y)-image:getWidth()),(toMake:getBottom()-toMake.y-50),(toMake:getBottom()-toMake.y),50}},{{-((toMake:getBottom()-toMake.y)-image:getWidth()),toMake:getBottom()-toMake.y-50,toMake:getBottom()-toMake.y,50}})
end

function inFightGamestate.load()
	image = love.graphics.newImage("Images/Brett.png")
 	canvas = love.graphics.newCanvas(640,360)
	local speed = 167
	entities = {}
	mapping = {l = 'l',r = 'r',d = 'd', u = 'u', rd = "rd",ru = "ru", ld = "ld", lu = "lu", a = "LK", b = "MK", triggerright = "HK", x = "LP", y = "MP", rightshoulder = "HP"}
	mapping2 = {a = 'l' ,d = 'r',w = 'u',s = 'd', f = 'LP', g = 'MP',h= 'HP', c = 'LK', v = 'MK', b = 'HK'}
	handler = inputHandler(love.joystick.getJoysticks()[1],mapping)
	handler2 = inputHandler("keyboard",mapping2)
	
	startGame()
end

function startGame()
	--set up camera
	playCamera = camera()
	playCamera:reset()
	
	--define characters
	c1 = char(825,152,handler2)
	c2 = char(1020,152,handler)
	
	playCamera:init(c1,c2)

	--Initialize characters by factory method
	makeTestChar(c1,c2)
	makeTestChar(c2,c1)
	
	--initialize GUI
	activeGUI = gui()
	activeGUI:addElement(healthBar(c1,25,25,"left"))
	activeGUI:addElement(healthBar(c2,395,25,"right"))
	activeGUI:addElement(timer(308,25,25,25,90))

	--Prepare test background
	love.graphics.setCanvas(background)
	love.graphics.setColor(0,0,0)
	local i = 0
	while i < 5200 do
		local j = 0
		while j < 360 do
			love.graphics.rectangle("line",i,j,100,100)
			j = j + 100
		end
		i = i+100
	end
	love.graphics.setCanvas()
	love.graphics.setBackgroundColor(0,53,255)
end

function inFightGamestate.draw()
	love.graphics.setColor(255,255,255)

	--Update Window dimensions
	local width,height = love.graphics.getDimensions()

	--Prepare the character layer
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	love.graphics.push()
	playCamera:applyTransformations()
	love.graphics.setColor(0,10,150)
	love.graphics.rectangle("fill",0,299,3200,360)
	c1:draw()
	c2:draw()
	for k,v in ipairs(entities) do
		v:draw()
	end
	love.graphics.setCanvas()
	love.graphics.pop()

	--Draw the background
	love.graphics.setColor(255,255,255)
	love.graphics.push()
	playCamera:applyTransformations(width/640,height/360)
	love.graphics.draw(background,0,0,0,width/640,height/360)
	love.graphics.pop()

	--Draw the 3 Layers(GUI-Back,Characters,GUI-Front)
	activeGUI:drawBackLayer(width/640,height/360)
	love.graphics.draw(canvas,0,0,0,width/640,height/360)
	activeGUI:drawFrontLayer(width/640,height/360)
	love.graphics.setColor(255,255,255)

	--Print debug information
	love.graphics.print("FPS:"..math.floor(fps),0,0)
	love.graphics.print("c1 - x:"..c1.x.." y:"..c1.y,300,0)
	love.graphics.print("c2 - x:"..c2.x.." y:"..c2.y,700,0)
	love.graphics.print("Camera:"..playCamera.x,0,100)
	love.graphics.print("Offset:"..playCamera.offset,0,150)
end

function inFightGamestate.update(dt)
	playCamera:update()
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
	activeGUI:update()
end

--event handler
function inFightGamestate.keypressed(key)
	inputHandler.keypressed(key)
end

function inFightGamestate.keyreleased(key)
	inputHandler.keyreleased(key)
end

function inFightGamestate.gamepadpressed(joystick,button)
	inputHandler.gamepadpressed(joystick,button)
end

function inFightGamestate.gamepadreleased(joystick,button)
	inputHandler.gamepadreleased(joystick,button)
end

function inFightGamestate.gamepadaxis(joystick,axis,value)
	inputHandler.gamepadaxis(joystick,axis,value)
end

function inFightGamestate.joystickhat(joystick,hat,direction)
	inputHandler.joystickhat(joystick,hat,direction)
end

return inFightGamestate
