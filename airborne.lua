local state = require "state"

local MAP_BOTTOM = 1000
local airborne = {}

setmetatable(airborne,airborne)

airborne.__index = state

function airborne:update()
	print(self.c1:getHeight(),self.c1.state.collisionboxes[1].y-self.c1.y)
	if self.c1:getBottom() and self.yVel >= 0 and self.c1:getBottom() >= MAP_BOTTOM then
		self.c1:move(0,MAP_BOTTOM-self.c1:getBottom(),self.c2)
		if self.fallbackState then self.fallbackState:acquireBoxes() end
		self:fallback()
	else
		self.yVel=self.yVel+3000/60
		self.c1:move(self.xVel/60,self.yVel/60,self.c2)
		if self.hitboxes then for k,v in ipairs(self.hitboxes) do
			v.setX(v.x+xVel)
			v.setY(v.y+yVel)
		end end
	end
	if self.yVel > 0 then for k,v in ipairs(self.collisionboxes) do
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
	end end
end

return airborne