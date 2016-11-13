local state = require "state"

local knockdown = {}
setmetatable(knockdown,knockdown)
knockdown.__index = state

function knockdown:__call(c1,c2,length)
	local nt = state(c1,c2,{},{},{},{})
	nt.length = length
	setmetatable(nt,{__index = knockdown})
	return nt
end

function knockdown:update()
	self.length = self.length - 1
	if self.length <= 0 then 
		self.c1:setState(self.c1.standing)
	end
end

function knockdown:acquireBoxes()
	self.collisionboxValues = self.c1.knockupCollisionboxes
end

function knockdown:flipBoxes()
	state.flipBoxes(self)
	if not self.c1.lookingRight then
		for k,v in ipairs(self.collisionboxes) do
			v:setX(v.x + self:getWidth())
		end
		for k,v in ipairs(self.hurtboxes) do 
			v:setX(v.x + self:getWidth())
		end
	else
		for k,v in ipairs(self.collisionboxes) do
			v:setX(v.x - self:getWidth())
		end
		for k,v in ipairs(self.collisionboxes) do
			v:setX(v.x - self:getWidth())
		end
	end
end

return knockdown
