local state = require "state"

local sliding = {}

setmetatable(sliding,sliding)

function sliding:__call(xVel,friction)
	local nt = {xVel = xVel,friction = friction}
	nt.xVelPositive = nt.xVel > 0
	setmetatable(nt,{__index = sliding})
	return nt
end

function sliding:update(ch,ch2)
	print(self.xVel)
	ch:move(self.xVel,0,ch2)
	if self.xVelPositive then
		self.xVel = self.xVel - self.friction
		if self.xVel <= 0 then ch:removeBonus(self) end
	else
		self.xVel = self.xVel + self.friction
		if self.xVel >= 0 then ch:removeBonus(self) end
	end
end

return sliding