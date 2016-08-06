local attack = require "attack"

local standing = {}
setmetatable(standing,standing)

function standing:__index(key)
	return rawget(standing,key)
end

function standing:__call(character1, character2)--character one is assumed to be the character owning this state
	nt = {["c1"] = character1, ["c2"] = character2}
	setmetatable(nt,standing)
	return nt
end

function standing:handleInput(inputs)
		if self.c1.handler:isTapped('MP') then 
			self.c1.state = attack(self.c1,self.c2,5,3,10,{rect(162+self.c1.x,90+self.c1.y,110,57)}) 
			return 
		end
		if self.c1.handler:isHeld('l') then 
				self.c1:move(-500*1/60,0,self.c2)  -- horizontal movement
		elseif self.c1.handler:isHeld('r') then 
				self.c1:move(500*1/60,0,self.c2)  -- horizontal movement
		end
end

function standing:update()
	--probably where the standing/walking animation would be played
end


function standing:isBlocking()
	if self.c1.lookingRight and self.c1.handler:isHeld(l) or not self.c1.lookingRight and self.c1.handler:isHeld('r') then return 'H' end
end

return standing