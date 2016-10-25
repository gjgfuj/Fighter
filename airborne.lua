local state = require "state"
local knockup

local MAP_BOTTOM = 333
local airborne = {}

airborne.isAirborneState = true -- if not otherwise specified all checks of this condition on airborne states should fall back onto this state

setmetatable(airborne,airborne)

airborne.__index = state

function airborne:update()
	if self.c1:getBottom() and self.yVel >= 0 and self.c1:getBottom() >= MAP_BOTTOM then
		self.c1:move(0,MAP_BOTTOM-self.c1:getBottom(),self.c2)
		if self.fallbackState and not self.fallbackState.hurtboxValues then self.fallbackState:acquireBoxes() end
		self:fallback()
	else
		self.yVel=self.yVel+0.25
		self.c1:move(self.xVel,self.yVel,self.c2,true)
	end
	if self.yVel > 0 then for k,v in ipairs(self.collisionboxes) do
		for k2,v2 in ipairs(self.c2.state.collisionboxes) do
			if(v:collide(v2)) then
				local vmid = v.x + (v.endx - v.x)/2
				local v2mid = v2.x + (v2.endx-v2.x)/2
				if vmid >= v2mid then 
					self.c1:move(2,0,self.c2,true)
					self.c2:move(-2,0,self.c1,true)
				else
					self.c1:move(-2,0,self.c2,true)
					self.c2:move(2,0,self.c1,true)
				end
			end
		end
	end end
end

function airborne:setState(toSet)
	if(not toSet.overwriteVel and toSet.isAirborneState) then
		modifiedState = toSet:copy()--Copy the state as not to overwrite Prototype values
		--replace the velocitys so the motion will appear uninterrupted
		modifiedState.xVel = self.xVel
		modifiedState.yVel = self.yVel
		state.setState(self,modifiedState)
	else
		state.setState(self,toSet)
	end
end

function airborne:handleHit(damage,chip,effect)
	if(effect.isAirborneState) then
		self.c1:doDamage(damage)
		self.c1:setState(effect)
	else
		if not knockup then knockup = require "knockup" end
		self.c1:doDamage()
		local knockupEffect = knockup(self.c1,self.c2,1,0,self.c1.standing)
		knockupEffect.overwriteVel=true
		knockupEffect:acquireBoxes()
		self.c1:setState(knockupEffect)
	end
end

return airborne
