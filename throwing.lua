local state = require "state"

local throwing = {}

setmetatable(throwing,throwing)

throwing.__index = state

function throwing:__call(c1,c2,duration)
	local nt = state(c1,c2,{},{},{},{})
	setmetatable(nt,{__index=throwing})
	nt.duration = duration
	return nt
end

function throwing:update()
	self.duration = self.duration - 1
	if(self.duration <= 0) then
		self:fallback()
	end
end

return throwing
