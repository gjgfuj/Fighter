local state = require "state"
local sliding = require "sliding"

local attack = {}
setmetatable(attack,attack)
--
function attack:__index(key)
	result = rawget(attack,key) or rawget(state,key)
	return result
end

function attack:__call(ch1,ch2,s,a,r,hitb,damage,chip,effect,blockEffect)
	local nt = {c1 = ch1, c2 = ch2, startup = s, active = a, recovery = r, frames_passed = 0, onFrame = {},patterns = {}, fpcombinations = {}, combinations = {}, damage = damage,chip = chip,effect = effect,blockEffect = blockEffect,inputsRight = true}
	if hitb then nt.hitboxValues = hitb end
	nt.slide = sliding(nt.c2,nt.c1,30,{},{},{},{})
	nt.slide:addCollisionbox(0,0,226,800)
	nt.slide:addHurtbox(0,0,226,800)
	setmetatable(nt,attack)
	return nt 
end

function attack:update()
	self.frames_passed = self.frames_passed + 1
	if self.onFrame[self.frames_passed] then self.onFrame[self.frames_passed](self) end
	if self.frames_passed <= self.startup then if self.inStartup then self:inStartup() end --if you're still in startup frames do nothing
	elseif self.frames_passed <= self.startup+self.active then -- if you're in active frames then check for collision
		if self.beforeCollisionCheck then self:beforeCollisionCheck() end
		if self.hitboxes then 
			for k1,v1 in ipairs(self.hitboxes) do
				for k2,v2 in ipairs(self.c2.state.hurtboxes) do
					if(v1:collide(v2)) then 
						self:resolveHit()
						self.hitboxes = nil -- when a hit occurs despawn the hitboxes
					end
				end
			end
		end
		if self.afterCollisionCheck then self:afterCollisionCheck() end
	elseif self.frames_passed <= self.startup+self.active+self.recovery then if self.inRecovery then self:inRecovery() end --in recovery frames just do nothing again
	else self.c1:setState(self.c1.standing:copy()) end
end

function attack:resolveHit()
		self.effect.hurtboxValues,self.effect.collisionboxValues = self.c2:supplyBoxes()
		self.c2:handleHit(self.damage,self.chip,self.effect,self.blockEffect,self.level)
end

function attack:draw()
	if self.drawHook then self.drawHook(self) end
	if self.hitboxes and self.frames_passed >= self.startup and self.frames_passed <= self.startup+ self.active then
		love.graphics.setColor(0,255,255)
		for k,v in ipairs(self.hitboxes) do
			love.graphics.rectangle("line",v.x,v.y,v.width,v.height)
		end
	end
end

function attack:copy()
	local nt = state.copy(self)
	nt.hitboxes = {}
	for k,v in pairs(nt.hitboxValues) do
		table.insert(nt.hitboxes,rect(v[1]+nt.c1.x,v[2]+nt.c1.y,v[3],v[4]))
	end
	return nt
end

return attack