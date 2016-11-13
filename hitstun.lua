local state = require "state"
local sliding = require "sliding"
local camera = require "camera"

local friction = 0.5
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
		self.c1:setState(self.c1.standing)
	end
end

function hitstun:init()
	local distance = self.pushback 
	distance = distance/friction
	local remainder = 0 --Holds the remainder the attacker must be pushed back by
	for k,v in ipairs(self.c1.state.collisionboxes) do
		if self.c2.lookingRight and MAP_WIDTH-v.endx < self.pushback then
			local buffer = (self.pushback-(MAP_WIDTH-v.endx)) 
			print(buffer,remainder,self.pushback,distance)
			if remainder == 0 or buffer > remainder then remainder = buffer print("remainder changed to "..remainder) end 
		elseif not self.c2.lookingRight and v.x < self.pushback then
			local buffer = self.pushback-v.x,friction
			if remainder == 0 or buffer > remainder then remainder = buffer end

		end
	end
	local startVel = sliding.calcStartVel(remainder/friction,friction)
	if self.c2.lookingRight then startVel = -startVel end
	print("B",remainder/friction,startVel)
	if remainder ~= 0 then print(startVel) self.c2:addBonus(sliding(startVel,friction,10),self.c1) end
	--calculate the required starting Velocity to travel the specified distance
	local startVel = sliding.calcStartVel(distance,friction)
	if not self.c2.lookingRight then startVel = -startVel end
	print("C",distance,startVel)
	self.c1:addBonus(sliding(startVel,friction,10),self.c2)
end

return hitstun
