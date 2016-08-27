local state = require "state"

local sliding = {}

setmetatable(sliding,sliding)

sliding .__index = state

function sliding:__call(c1,c2,xVel,buttons,combinations,fpcombinations,patternStates)
	local nt = {c1 = c1,c2 = c2,xVel = xVel,buttons = buttons, combinations = combinations, fpcombinations = fpcombinations, patternStates = patternStates}
	nt.xVelPositive = nt.xVel > 0
	nt.patterns = {}
	for k,v in ipairs(nt.patternStates) do
		table.insert(nt.patterns,k)
	end
	setmetatable(nt,{__index = sliding})
	return nt
end

function sliding:update()
	self.c1:move(self.xVel,0,self.c2)
	if self.xVelPositive then
		self.xVel = self.xVel -5
		if self.xVel <= 0 then self.c1:setState(self.c1.standing:copy()) end
	else
		self.xVel = self.xVel + 5
		if self.xVel >= 0 then self.c1:setState(self.c1.standing:copy()) end
	end
end

return sliding