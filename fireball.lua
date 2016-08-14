local rect = require "rect"

local fireball = {}

setmetatable(fireball,fireball)

function fireball:__index(key)
	return rawget(fireball,key)
end

function fireball:__call(target,x,y,width,height,vel,c1)
	local nt = {target = target, hitb = rect(x,y,width,height), vel = vel, c1 = c1}
	setmetatable(nt,fireball)
	return nt
end

function fireball:update()
	if self.hitb then 
		self.hitb:setX(self.hitb.x + self.vel/60)
		for k,v in ipairs(self.target.state.hurtboxes) do
			if self.hitb and self.hitb:collide(v) then
				self.target:move(200*(self.vel/math.abs(self.vel)),0,self.c1)
				for k,v in ipairs(entities) do
					if v == self then
						table.remove(entities,k)
					end
				end
			end
		end
	end
end

function fireball:draw()
	love.graphics.setColor(0,255,255)
	if self.hitb then love.graphics.rectangle("line",self.hitb.x,self.hitb.y,self.hitb.width,self.hitb.height) end
end

return fireball