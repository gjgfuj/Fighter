local attack = require "attack"
local state = require "state"

local standing = {}
setmetatable(standing,standing)

standing.__index = state

function standing:__call(character1, character2,buttons,combinations,fpcombinations,patternStates)--character one is assumed to be the character owning this state
	nt = {["c1"] = character1, ["c2"] = character2,buttons = buttons, combinations = combinations,fpcombinations = fpcombinations, patternStates = patternStates, patterns = {},inputsRight = true}
	for k in pairs(nt.patternStates) do
		table.insert(nt.patterns,k)
	end
	setmetatable(nt,{__index = standing})
	return nt
end

function standing:update()
	if not self:checkInputs() then 
		if self.c1.handler:isHeld('l') then 
			self.c1:move(-500*1/60,0,self.c2)  -- horizontal movement
		elseif self.c1.handler:isHeld('r') then 
			self.c1:move(500*1/60,0,self.c2)  -- horizontal movement
		elseif self.c1.handler:isHeld('d') or self.c1.handler:isHeld('ld') or self.c1.handler:isHeld('rd') then
			self.c1:setState(self.c1.crouching:copy())
		elseif self.c1.handler:isHeld('u') then
			self.c1:setState(self.c1.jumping:copy())
		elseif self.c1.handler:isHeld('ru') then
			self.c1:setState(self.c1.jumpForward:copy())
		elseif self.c1.handler:isHeld('lu') then 
			self.c1:setState(self.c1.jumpBack:copy())
		end
	end
end


function standing:isBlocking()
	if self.c1.lookingRight and self.c1.handler:isHeld(l) or not self.c1.lookingRight and self.c1.handler:isHeld('r') then return 'H' end
end

return standing