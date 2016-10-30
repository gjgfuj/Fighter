MAP_WIDTH = 1920

local camera = {}

local instance -- Camera is a Singleton(how would there be more than one?)

setmetatable(camera,camera)

function camera:__call()
	if not instance then
		instance = {x = 640,offset = 0}
		setmetatable(instance,{__index = camera})
	end
	return instance
end

function camera:init(c1,c2)
	if not instance then camera() end
	instance.c1 = c1
	instance.c2 = c2
end

function camera:reset()
	self.x = 640
	self.offset = 0
end

local function calculateMiddle(self)
	local distance
	if self.c1.lookingRight then
		distance =self.c2.x-(self.c1.x+75)
		return (self.c1.x + 75)+distance/2,distance
	else
		distance = self.c1.x-(self.c2.x+75)
		return (self.c2.x + 75)+distance/2,distance
	end
end

function camera:update()
	local mid,distance = calculateMiddle(self)-- the point central between the characters
	self.offset = (self.x+320) - mid
	self.x = mid -320
	if self.x < 0 then self.x= 0
	elseif self.x > MAP_WIDTH-640 then self.x = MAP_WIDTH-640 end
--[[	if distance >= 150 then
		self.x = mid-320
	elseif self.offset >= 150 then 
		self.x = self.x + (self.offset-150)	
	elseif self.offset <= -150 then
		self.x = self.x - (self.offset-150)
	end]]
	self.offset = (self.x+320) -mid
end

function camera:applyTransformations()
	love.graphics.translate(-self.x,0)
end

return camera
