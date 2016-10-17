local state = require "state"

local crouching = {}

setmetatable(crouching,crouching)

function crouching:__call(c1,c2,buttons,combinations,fpcombinations,patternStates)
	local nt = state(c1,c2,buttons,combinations,fpcombinations,patternStates)
	setmetatable(nt,{__index = crouching})
	return nt
end

crouching.__index = state

function crouching:update()
	if(self.c1.x < self.c2.x ~= self.c1.lookingRight) then
	    self.c1:flip(226)
	end
	if not self:checkInputs() then
		if not(self.c1.handler:isHeld('ld') or self.c1.handler:isHeld('d') or self.c1.handler:isHeld('rd')) then
			self.c1:setState(self.c1.standing)
		end
	end
end

return crouching