local state = require "state"

local crouching = {}

setmetatable(crouching,crouching)

function crouching:__call(c1,c2,buttons,combinations,fpcombinations,patternStates)
	local nt = {c1 = c1,c2 = c2,buttons = buttons, combinations = combinations, fpcombinations = fpcombinations, patternStates = patternStates}
	nt.patterns = {}
	for k,v in pairs(nt.patternStates) do
		table.insert(patterns,k)
	end
	setmetatable(nt,{__index = crouching})
	return nt
end

crouching.__index = state

function crouching:update()
	if not self:checkInputs() then
		if not(self.c1.handler:isHeld('ld') or self.c1.handler:isHeld('d') or self.c1.handler:isHeld('rd')) then
			self.c1:setState(self.c1.standing:copy())
		end
	end
end

return crouching