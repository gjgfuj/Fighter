local airborne = require "airborne"
local state = require "state"

local jumping = {}

setmetatable(jumping,jumping)

jumping.__index = airborne

function jumping:__call(c1,c2,xVel,yVel,buttons,combinations,fpcombinations,patternStates)
	local nt = state(c1,c2,buttons,combinations,fpcombinations,patternStates)
	nt.xVel = xVel
	nt.yVel = yVel
	setmetatable(nt,{__index = jumping})
	return nt
end

function jumping:update()
	self:checkInputs()
	airborne.update(self)
end

return jumping