local rect = require("rect")

local char = {}
setmetatable(char,char)
function char:__index(key)
	return rawget(char,key)
end
function char:__call(nx,ny,handler)
	c = {["x"] = nx,["y"] = ny,["collisionboxes"] = {},["hurtboxes"] = {}, ["lookingRight"]=true, ["width"] = 0, handler = handler, word = "none"}
	setmetatable(c,char)
	return c
end

function char:setStanding(newStanding)
	print(newStanding)
	self.standing = newStanding
	self.state = self.standing:copy()
end

function char:addHurtbox(hx,hy,width,height)
	table.insert(self.hurtboxes,char.hurtbox(self.x+hx,self.y+hy,width,height)) -- place the hurtboxes in the relative grid
	-- This makes initializing hurtboxes consistent regardless of character position
end

function char:addCollisionbox(hx,hy,width,height)
	table.insert(self.collisionboxes,rect(self.x+hx,self.y+hy,width,height)) -- place the hurtboxes in the relative grid
	-- Probably refactor since these two functions are same
end

local function doMove(self,xVel,yVel)
	 --change character coordinates
	self.x = self.x+xVel
	self.y = self.y+yVel
	--move all Hurtboxes
	for k,v in ipairs(self.hurtboxes) do
	v:setX(v.x+xVel)
	v:setY(v.y+yVel)
	end
	for k,v in ipairs(self.collisionboxes) do
	v:setX(v.x+xVel)
	v:setY(v.y+yVel)
	end
end

local function checkCollision(self,otherChar,xVel,yVel)
	if xVel < 0 then -- when moving to the left
		for k,v in ipairs(self.collisionboxes) do
			for k2,v2 in ipairs (otherChar.collisionboxes) do
				if(v:collide(v2) and v2.x <= v.x) then 
					return true
				end
			end
		end
	elseif xVel > 0 then --when moving to the right
		for k,v in ipairs(self.collisionboxes) do
			for k2,v2 in ipairs (otherChar.collisionboxes) do
				if(v:collide(v2) and v2.endx >= v.endx) then 
					return true
				end
			end
		end
	end
end

function char:move(xVel,yVel,otherChar)
	if(not checkCollision(self,otherChar,xVel,yVel)) then
			doMove(self,xVel,yVel)
	else
		doMove(self,xVel/2,yVel)
		otherChar:move(xVel/2,yVel,self)
	end		
end

--the two functions below definitely need to be cleaned up
local function flipBox(box,width,self)-- takes a rect and flips it width refers to the width of the character!
	local nx = box.x-self.x --get the hurtboxe's "local" coordinates
		nx = nx+box.width --get the upper right corner
		nx = nx-width  --move the y axis to the middle of the character
		box:setX(-nx+self.x) --mirror the upper right corner,as width and height stay the same it falls into place
end

function char:flip(width)--this one's most likely temporary
	self.lookingRight = not self.lookingRight
	self.width = width
	for k,v in ipairs(self.hurtboxes) do 
		flipBox(v,width,self)
	end
	for k,v in ipairs(self.collisionboxes) do
		flipBox(v,width,self)
	end
end

function char:draw(coord,name)
	love.graphics.setColor(255,255,255) -- set color to white
	love.graphics.print("x:"..self.x.." y:"..self.y,coord,0)
	if self.state.word then love.graphics.print(self.state.word,self.x,self.y-50) end
	for k,v in ipairs(self.collisionboxes) do love.graphics.rectangle("line",v.x,v.y,v.width,v.height) end
	love.graphics.setColor(255,0,0)--set color to red
	for k,v in ipairs(self.hurtboxes) do love.graphics.rectangle("line",v.x,v.y,v.width,v.height)	end -- draw hurtboxes for debugging
	if self.state.draw then self.state:draw() end
end

function char:handleInput(inputs)
	self.state:handleInput(inputs)
end

function char:update()
	self.state:update()
	self.handler:update()
	if(self.image) then 
		if(self.lookingRight) then love.graphics.draw(self.image,self.x,self.y) --draw the sprite if available
		else love.graphics.draw(self.image,self.x,self.y,0,-1,1,self.width,0) end end	
	love.graphics.setColor(0,255,0)
end

function char:queueState(state)
	self.nextState = state
end

function char:isBlocking()
	return self.state:isBlocking()
end

--inner class hurtbox
local hurtbox = {}
setmetatable(hurtbox,hurtbox)
hurtbox.__index = rect
function hurtbox:__call(x,y,width,height)
	return rect(x,y,width,height)
end 
char.hurtbox = hurtbox

return char