local state = require "state"
local attack  = require "attack"

local throw = {}

setmetatable(throw,throw)

throw.__index = attack

function throw:__call(c1,c2,s,a,r,throwb,damage,partnerState,execution)--partnerState refers to the state the target is put in if the throw connects"
	local nt = attack(c1,c2,s,a,r,throwb,damage,0,partnerState)
	setmetatable(nt,{__index=throw})
	nt.execution = execution
	nt.execution.duration = nt.effect:predictLength()
	return nt
end

function throw:activeFrames()
	if self.beforeCollisionCheck then self:beforeCollisionCheck() end
	for k,v in ipairs(self.hitboxes) do
		for k2,v2 in ipairs(self.c2.state.hurtboxes) do
			if v2:hasFlag("throwable") and v:collide(v2) then
				self:resolveHit()
				self.hitboxes = nil
				return
			end
		end
	end
	if self.afterCollisionCheck then self:afterCollisionCheck() end
end

function throw:resolveHit()
	distributeEvents("Throw",self.c1,self.c2)
	self.c2:queueState(self.effect)
	self.c1:setState(self.execution)
end

return throw
