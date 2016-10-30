local attack = require "attack"
local state = require "state"

local standing = {}
setmetatable(standing,standing)

standing.__index = state

function standing:__call(character1, character2,buttons,combinations,fpcombinations,patternStates)--character one is assumed to be the character owning this state
	local nt = state(character1, character2,buttons,combinations,fpcombinations,patternStates)
	setmetatable(nt,{__index = standing})
	return nt
end

function standing:checkInputs()
	if not state.checkInputs(self) then 
		if self.c1.handler:isHeld('l') then 
			self.c1:move(-4,0,self.c2)  -- horizontal movement
		elseif self.c1.handler:isHeld('r') then 
			self.c1:move(4,0,self.c2)  -- horizontal movement
		elseif self.c1.handler:isHeld('d') or self.c1.handler:isHeld('ld') or self.c1.handler:isHeld('rd') then
			self.c1:setState(self.c1.crouching)
		elseif self.c1.handler:isHeld('u') then
			self.c1:setState(self.c1.jumping)
		elseif self.c1.handler:isHeld('ru') then
			self.c1:setState(self.c1.jumpForward)
		elseif self.c1.handler:isHeld('lu') then 
			self.c1:setState(self.c1.jumpBack)
		end
	end
end

function standing:update()
	if(self.c1.x < self.c2.x ~= self.c1.lookingRight) then
	    self.c1:flip(226)
	end
	self:checkInputs()
end

function standing:handleHit(damage,chip,hitEffect,blockEffect,level)
	if self.c1.handler:isHeld(self.c1.back) and level ~= 'L' then --if the player is holding back here he is blocking high
		distributeEvents("Block",self.c2,self.c1)
		self.c1:doDamage(chip)
		self.c1:queueState(blockEffect)
	else
		distributeEvents("Hit",self.c2,self.c1)
		self.c1:doDamage(damage)
		self.c1:queueState(hitEffect)
	end
end


return standing
