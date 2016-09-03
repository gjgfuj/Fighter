local state = require "state"

local knockdown = {}
setmetatable(knockdown,knockdown)
knockdown.__index = state

function knockdown:__call(c1,c2,length)
	local nt = state(c1,c2,{},{},{},{})
	nt.length = length
	print(nt.length)
	setmetatable(nt,{__index = knockdown})
	return nt
end

function knockdown:update()
	self.length = self.length - 1
	if self.length <= 0 then 
		self.c1:setState(self.c1.standing:copy())
	end
end

function knockdown:acquireBoxes()
	print("Boxes yay")	
	self.collisionboxValues = self.c1.knockupCollisionboxes
end

return knockdown