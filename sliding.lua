local state = require "state"

local sliding = {}

setmetatable(sliding,sliding)

function sliding:__call(xVel)
	local nt = {xVel = xVel}
	nt.xVelPositive = nt.xVel > 0
	setmetatable(nt,{__index = sliding})
	return nt
end

function sliding:update(ch,ch2)
	print(ch.state.hurtboxes[4].x,ch.x)
	ch:move(self.xVel,0,ch2)
	if self.xVelPositive then
		self.xVel = self.xVel -5
		if self.xVel <= 0 then ch:removeBonus(self) end
	else
		self.xVel = self.xVel + 5
		if self.xVel >= 0 then ch:removeBonus(self) end
	end
end

return sliding