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
		self.c1:move(self.xVel/60,self.yVel/60,self.c2)
	end
	for k,v in ipairs(self.collisionboxes) do
		for k2,v2 in ipairs(self.c2.state.collisionboxes) do
			if(v:collide(v2)) then
				local vmid = self.c1.x + (v.endx - v.x)/2
				local v2mid = self.c2.x + (v2.endx-v2.x)/2
				if vmid > v2mid then 
					self.c1:move(10,0,self.c2,true)
				else
					self.c1:move(-10,0,self.c2,true)
				end
			end
		end
	end
end

return airborne