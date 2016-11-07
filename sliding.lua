local state = require "state"

local sliding = {}

setmetatable(sliding,sliding)

function sliding.calcStartVel(distance,friction)
	return (-0.5+math.sqrt(0.25+2*distance))*friction
end

function sliding:__call(xVel,friction,delay)
	local nt = {xVel = xVel,friction = friction,delay = delay}
	if not delay then
		nt.delay = 0
	end
	nt.xVelPositive = nt.xVel > 0
	setmetatable(nt,{__index = sliding})
	return nt
end

function sliding:update(ch,ch2)
	if self.delay > 0 then 
		self.delay = self.delay - 1
	else
		ch:move(self.xVel,0,ch2)
		if self.xVelPositive then
			self.xVel = self.xVel - self.friction
			if self.xVel <= 0 then ch:removeBonus(self) end
		else
			self.xVel = self.xVel + self.friction
			if self.xVel >= 0 then ch:removeBonus(self) end
		end
	end
end

return sliding
