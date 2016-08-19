local state = require "state"

local MAP_BOTTOM = 1000
local airborne = {}

setmetatable(airborne,airborne)

airborne.__index = state

function airborne:update()
	if self.c1:getBottom() and self.yVel >= 0 and self.c1:getBottom() >= MAP_BOTTOM then
		self.c1:setState(self.c1.standing:copy())
	else
		self.yVel=self.yVel+3000/60
		self.c1:move(0,self.yVel/60,self.c2)
	end
end

return airborne