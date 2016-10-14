local attack = require "attack"
local airborne = require "airborne"
local jumping = require "jumping"

local jumpingAttack = {}

setmetatable(jumpingAttack,jumpingAttack)

jumpingAttack.__index = attack

function jumpingAttack:__call(c1,c2,xVel,yVel,s,a,r,hitb,damage,chip,effect,blockEffect)
	local nt = attack(c1,c2,s,a,r,hitb,damage,chip,effect,blockEffect)
	nt.xVel = xVel
	nt.yVel = yVel
	return nt
end

function jumpingAttack:update()
	attack.update(self)
	airborne.update(self)
end

function jumpingAttack:fallback()
	local newJumping = self.c1.jumping:copy()
	newJumping.xVel = self.xVel
	newJumping.yVel = self.yVel
	self.c1:setState(newJumping:copy())
end

return jumpingAttack