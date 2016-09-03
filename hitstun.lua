local state = require "state"
local sliding = require "sliding"

local friction = 1
local hitstun = {}

hitstun.type = "hitstun"
setmetatable(hitstun,hitstun)

hitstun.__index = state

function hitstun:__call(c1,c2,length,pushback)
	local nt = state(c1,c2,{},{},{},{})
	nt.length = length
	nt.pushback = pushback
	setmetatable(nt,{__index = hitstun})
	return nt
end

function hitstun:update()
	self.length = self.length-1
	if self.length <= 0 then
		self.c1:setState(self.c1.standing:copy())
	end
end

function hitstun:init()
	local distance = self.pushback 
	distance = distance/friction
	local startVel = (-0.5+math.sqrt(0.25+2*distance))*friction
	if not self.c2.lookingRight then startVel = -startVel end
	self.c1:addBonus(sliding(startVel,friction),self.c2)
end

return hitstun