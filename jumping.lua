local jumping = {}

setmetatable(jumping,jumping)

jumping.__index = state

function jumping:__call()
	nt = {}
	setmetatable(nt,{__index = jumping})
	return nt
end

function airborne:update()
	for k,v in ipairs(self.c1.collisionboxes) do
		
	end
end