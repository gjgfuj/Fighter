local state = require "state"
local sliding = require "sliding"

local hitstun = {}

setmetatable(hitstun,hitstun)

hitstun.__index = state

function hitstun:__call(c1,c2,length)
	local nt = state(c1,c2,{},{},{},{})
	nt.length = length
	setmetatable(nt,{__index = hitstun})
	return nt
end

function hitstun:update()
	self.length = self.length-1
	if self.length <= 0 then
		self.c1:setState(self.c1.standing:copy())
	end
end

return hitstun