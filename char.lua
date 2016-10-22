local rect = require("rect")

local rotation = 0;
local char = {}
setmetatable(char,char)
function char:__index(key)
	return rawget(char,key)
end
function char:__call(nx,ny,handler)
	local c = {x = nx,  y = ny,collisionboxes = {},hurtboxes = {}, lookingRight =true, width = 0, handler = handler, word = "none", back = 'l', forward = 'r',bonus = {},bonusIndexes = {}, knockupHurtboxes = {}, knockupCollisionboxes = {},throwboxes = {}}
	setmetatable(c,char)
	return c
end

function char:setstanding(newstanding)
	self.standing = newstanding
	self:setState(self.standing)
end

function char:setCrouching(newCrouching)
	self.crouching = newCrouching
end

function char:setJumping(newJumping)
	self.jumping = newJumping
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
	for k,v in ipairs(self.state.hurtboxes) do
		v:setX(v.x+xVel)
		v:setY(v.y+yVel)
	end
	for k,v in ipairs(self.state.collisionboxes) do
		v:setX(v.x+xVel)
		v:setY(v.y+yVel)
	end
	if self.state.hitboxes then for k,v in ipairs(self.state.hitboxes) do
		v:setX(v.x+xVel)
		v:setY(v.y+yVel)
	end end 
	if self.throwboxes then for k,v in ipairs(self.throwboxes) do 
		v:setX(v.x+xVel)
		v:setY(v.y+yVel)
	end end
end


function char:setKnockupBoxes(hurt,colli)
	self.knockupHurtboxes = hurt
	self.knockupCollisionboxes = colli
end


local function checkCollision(self,otherChar,xVel,yVel)
	if xVel < 0 then -- when moving to the left
		for k,v in ipairs(self.state.collisionboxes) do
			for k2,v2 in ipairs (otherChar.state.collisionboxes) do
				if(v:collide(v2) and v2.x <= v.x) then
					return true,(v.x-v2.endx)+1
				end
			end
		end
	elseif xVel > 0 then --when moving to the right
		for k,v in ipairs(self.state.collisionboxes) do
			for k2,v2 in ipairs (otherChar.state.collisionboxes) do
				if(v:collide(v2) and v2.endx >= v.endx) then 
					return true,(v.endx -v2.x)-1
				end
			end
		end
	end
end

function char:move(xVel,yVel,otherChar,ignoreCollision)
	if(ignoreCollision or not checkCollision(self,otherChar,xVel,yVel)) then
			doMove(self,xVel,yVel)
			nowCollide,distance = checkCollision(self,otherChar,xVel,yVel)
			if not ignoreCollision and nowCollide then
				doMove(self,-distance,0)
			end
	else
		doMove(self,xVel/2,yVel,true)
		otherChar:move(xVel/2,0,self,true)
	end		
end

--the two functions below definitely need to be cleaned up
function flipBox(box,width,self)-- takes a rect and flips it width refers to the width of the character!
	local nx = box.x-self.x --get the hurtboxe's "local" coordinates
		nx = nx+box.width --get the upper right corner
		nx = nx-width  --move the y axis to the middle of the character
		box:setX(-nx+self.x) --mirror the upper right corner,as width and height stay the same it falls into place
end

function char:flip(width)--this one's most likely temporary
	width = 75
	self.lookingRight = not self.lookingRight 
	if not (self.lookingRight and self.back == 'l') or not (not self.lookingRight and self.back == 'r') then
		local backBuffer = self.back
		self.back = self.forward
		self.forward = backBuffer
	end
	self.width = width
	for k,v in ipairs(self.state.hurtboxes) do 
		flipBox(v,width,self)
	end
	for k,v in ipairs(self.state.collisionboxes) do
		flipBox(v,width,self)
	end
	if self.state.hitboxes then for k,v in ipairs(self.state.hitboxes) do
		flipBox(v,width,self)
	end end
end

function char:draw(coord,name)
	print(self.image)
	love.graphics.setColor(255,255,255) -- set color to white
	love.graphics.print("x:"..self.x.." y:"..self.y,coord,0)
	love.graphics.draw(self.image,self.x,self.y)
	if self.state.word then love.graphics.print(self.state.word,self.x,self.y-50) end
	for k,v in ipairs(self.state.collisionboxes) do love.graphics.rectangle("line",v.x,v.y,v.width,v.height) end
	love.graphics.setColor(255,0,0)--set color to red
	for k,v in ipairs(self.state.hurtboxes) do love.graphics.rectangle("line",v.x,v.y,v.width,v.height)	end -- draw hurtboxes for debugging
	love.graphics.setColor(255,255,0)
	if self.state.draw then self.state:draw() end
end

function char:handleInput(inputs)
	self.state:handleInput(inputs)
end

function char:supplyBoxes()
	return self.state:supplyBoxes()
end

function char:update(opponent)
	self.state:update()
	self.handler:update()
	
	for k,v in ipairs(self.bonus) do
		v:update(self,opponent)
	end
	
	love.graphics.setColor(0,255,0)
end

function char:queueState(state)
	self.nextState = state
end

function char:isBlocking()
	return self.state:isBlocking()
end

function char:setState(toSet)
	if self.state then 
		self.state:setState(toSet)
	else
		self.state=toSet:copy()
	end
	if not self.lookingRight then
		self.lookingRight = true
	    self:flip(226)
	end
	self.state:init()
	--self.state:update()
end

function char:setJumpForward(newJf)
	self.jumpForward = newJf
end

function char:setJumpBack(newJb)
	self.jumpBack = newJb
end

function char:getBottom()--returns the lowest coordinate of the character's collisionboxes
	return self.state:getBottom()
end

function char:handleHit(damage,chip,hitEffect,blockEffect)
	self.state:handleHit(damage,chip,hitEffect,blockEffect,level);
end

function char:doDamage(damage)
	--TODO
end

function char:addBonus(b,ch2)
	table.insert(self.bonus,b)
	self.bonusIndexes[b] = #self.bonus
end

function char:removeBonus(b)
	table.remove(self.bonus,self.bonusIndexes[b])
	self.bonusIndexes[b] = nil
end

function char:getHeight()
	return self:getBottom() - self.y
end

--inner class hurtbox
local hurtbox = {}
setmetatable(hurtbox,hurtbox)
hurtbox.__index = rect
function hurtbox:__call(x,y,width,height,flags)
	local nt = rect(x,y,width,height)
	setmetatable(nt,{__index = hurtbox})
	if flags then 
		nt.flags = flags 
	else 
		nt.flags = {} 
	end
	return nt
end 

function hurtbox:hasFlag(flag)
	for k,v in ipairs(self.flags) do
		if v == flag then return true end
	end
	return false
end

char.hurtbox = hurtbox

return char
