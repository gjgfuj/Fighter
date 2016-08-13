local rect = require "rect"

local fireball = {}

setmetatable(fireball,fireball)

function fireball:__index(key)
	return rawget(fireball,key)
end

function fireball:__call(target,x,y,width,height,vel)
	local nt = {target = target, hitb = rect(x,y,width,height), vel = vel}
	setmetatable(nt,fireball)
	return nt
end

function fireball:update()
	if self.hitb then 
		self.hitb:setX(self.hitb.x + self.vel/60)
		for k,v in ipairs(self.target.hurtboxes) do
			if self.hitb and self.hitb:collide(v) then
				self.target:move(200,0,c1)
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
	love.graphics.setColor(255,0,0)
	if self.hitb then love.graphics.rectangle("line",self.hitb.x,self.hitb.y,self.hitb.width,self.hitb.height) end
end

return fireball