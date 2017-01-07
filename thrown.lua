local state = require "state"
local knockdown = require "knockdown"

local thrown = {}

setmetatable(thrown,thrown)

thrown.__index = state

function thrown:__call(c1,c2,movements,offsetX,offsetY)
	local nt = state(c1,c2,{},{},{},{})
	nt.duration = duration
	nt.movements = movements
	nt.currPosition = 0
	nt.fallbackState = knockdown(c1,c2,30)--TODO set from outside
	nt.length = 0
	--Define the starting offset of the thrown character to the throwing one
	nt.offsetX = offsetX or 0
	nt.offsetY = offsetY or 0
	setmetatable(nt,{__index = thrown})
	return nt
end

function thrown:update()
	if not self.iter then
		self.currPosition = self.currPosition+1
		self.iter = self.movements[self.currPosition]:iterator()
	end

	if self.iter then
		--get the velocities
		local xVel,yVel,lastMove = self.iter()
		if self.turned then xVel = -xVel end

		--calculate the possible remainder on horizontal movement due to map borders
		local remainder = 0
		for k,v in ipairs(self.c1.state.collisionboxes) do
			if xVel > 0 and (MAP_WIDTH-v.endx)<xVel then
				local buffer = xVel-(MAP_WIDTH-v.endx)	
				if remainder == 0 or buffer > remainder then remainder = buffer end
			elseif xVel<0 and v.x < math.abs(xVel) then
				local buffer = math.abs(xVel)-v.x
				if remainder == 0 or bufffer < remainder then remainder = buffer end
			end
		end
		if self.turned then remainder = -remainder end

		--Apply the movement
		self.c1:move(xVel,yVel,self.c2,true)
		self.c2:move(remainder,0,self.c1,true)

		--Check if the iterator has more values to provide,if not discard it
		if lastMove and self.movements[self.currPosition+1] then
     			self.iter = nil
		elseif lastMove then
			self:fallback()
		end
	end
end

function thrown:predictLength()
	local result = 0
	for k,v in ipairs(self.movements) do
		result = result + v:predictLength()
	end
	return result
end

function thrown:init()
	self.turned = not self.c2.lookingRight
	if self.turned then
		self.c1:move((self.c2:getCollisionStart()-1)-self.c1.x-self.c1:getWidth()-self.offsetX,0,self.c2,true)
	else
		self.c1:move((self.c2.x+self.c2:getWidth()+1)-self.c1.x+self.offsetX,0,self.c2,true)
	end
end
--Inner classes of type 'movement'

--Movement representing the character moving along a straight line at a constant velocity
local straightLine = {}

setmetatable(straightLine,straightLine)

function straightLine:__call(c1,c2,len,step)
	 local nt = {c1,c2,len = len,step = step}
	 setmetatable(nt,{__index = straightLine})
	 --Make sure that the entire length can be exactly traversed with step
	 return nt
end

function straightLine:iterator()
	local passedWay = 0
	local len = self.len
	local step = self.step
	return function()
		passedWay = passedWay + step
		--Check whether this is the last provided value
		if math.abs(passedWay) >= math.abs(len) then
			return step,0,true
		else
			return step,0
		end
	end
end

function straightLine:predictLength()
	local result = self.len/self.step
	if(self.len%self.step ~= 0) then
		result = result +1
	end
	return result
end


thrown.straightLine = straightLine

return thrown
