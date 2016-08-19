local airborne = require "airborne"
local state = require "state"

local jumping = {}

setmetatable(jumping,jumping)

jumping.__index = airborne

function jumping:__call(c1,c2,vel,buttons,combinations,fpcombinations,patternStates)
	local nt = {c1 = c1,c2 = c2,yVel = vel,buttons = buttons,combinations = combinations,fpcombinations = fpcombinations,patternStates = patternStates}
	nt.patterns = {}
	nt.hurtboxes = {}
	nt.collisionboxes = {}
	if self.patternStates then for k,v in ipairs(self.ṕatternStates) do
		table.insert(self.patterns,k)
	end end
	setmetatable(nt,{__index = jumping})
	return nt
end

function jumping:update()
	state.checkInputs(self)
	airborne.update(self)
end

return jumping