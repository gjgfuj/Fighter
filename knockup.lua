local state = require "state"
local airborne = require "airborne"

local knockup = {}

setmetatable(knockup,knockup)

knockup.__index = airborne

function knockup:__call(c1,c2,xVel, yVel,fallEffect)
	local nt = state(c1,c2,{},{},{},{})
	setmetatable(nt,{__index = knockup})
	nt.xVel = xVel
	nt.yVel = yVel
	nt.fallbackState = fallEffect
	return nt
end

function knockup:acquireBoxes()
	self.hurtboxValues = self.c1.knockupHurtboxes
	self.collisionboxValues = self.c1.knockupCollisionboxes
end

function knockup:init()
	if not self.c2.lookingRight then
		self.xVel = -self.xVel
	end
end

return knockup