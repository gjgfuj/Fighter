local state = require "state"
local knockdown = require "knockdown"

local thrown = {}

setmetatable(thrown,thrown)

thrown.__index = state

function thrown:__call(c1,c2,duration,xDist,yDist)
	local nt = state(c1,c2,{},{},{},{})
	nt.duration = duration
	nt.xDist = xDist
	nt.yDist = yDist
	nt.fallbackState = knockdown(c1,c2,150)--TODO set from outside
	setmetatable(nt,{__index = thrown})
	return nt
end

function thrown:update()
	self.duration = self.duration - 1
	if self.duration <= 0 then
		assert(self.xDist ~= nil,"xDist is nil")
		self.c1:move(self.xDist,self.yDist,self.c2,true)
		self.fallbackState:acquireBoxes()
		self:fallback()
	end
end

function thrown:init()
	if not self.c2.lookingRight then self.xDist = -self.xDist end
end

return thrown
