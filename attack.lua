local attack = {}
setmetatable(attack,attack)

function attack:__index(key)
	return rawget(attack,key)
end

function attack:__call(ch1,ch2,s,a,r,hitb,effect)
	nt = {startup = s, active = a, recovery = r, frames_passed = 0}
	if hitb then nt.hitboxes = hitb end
	setmetatable(nt,attack)
	nt.c1 = ch1
	nt.c2 = ch2
	return nt 
end

function attack:handleInput(...)
	if onInput then onInput(...) end
end

function attack:update()
	self.frames_passed = self.frames_passed + 1
	if self.frames_passed <= self.startup then if self.inStartup then self.inStartup() end --if you're still in startup frames do nothing
	elseif self.frames_passed <= self.startup+self.active then -- if you're in active frames then check for collision
		if self.beforeCollisionCheck then self.beforeCollisionCheck() end
		if self.hitboxes then 
			for k1,v1 in ipairs(self.hitboxes) do
				for k2,v2 in ipairs(self.c2.hurtboxes) do
					if(v1:collide(v2)) then 
						self:resolveHit()
						self.hitboxes = nil -- when a hit occurs despawn the hitboxes
					end
				end
			end
		end
		if self.afterCollisionCheck then self.afterCollisionCheck() end
	elseif self.frames_passed <= self.startup+self.active+self.recovery then if self.inRecovery then self.inRecovery() end --in recovery frames just do nothing again
	else self.c1.state = require "standing"(self.c1,self.c2) end --Once all of the attack's frames have passed return the player to standing state
end

function attack:resolveHit()
	if self.c2:isBlocking() then
		if self.blockEffect then self.c2:queueState(self.blockEffect) end
		print("A hit has been blocked")
	else 
		if self.hitEffect then self.c2:queueState(self.hitEffect) end
		print("A hit has occurred") --for now
	end
end

function attack:draw()
	if self.hitboxes and self.frames_passed >= self.startup and self.frames_passed <= self.startup+ self.active then
		love.graphics.setColor(0,255,255)
		for k,v in ipairs(self.hitboxes) do
			love.graphics.rectangle("line",v.x,v.y,v.width,v.height)
		end
	end
end

return attack