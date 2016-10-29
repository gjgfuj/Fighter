local timer = {}

local font = love.graphics.newFont(50)

setmetatable(timer,timer)

function timer:__call(x,y,width,height,seconds)
	local nt = {x = x,y = y,seconds = seconds,framesThisSecond = 0}
	setmetatable(nt,{__index = timer})
	print(nt.seconds)
	return nt
end

function timer:update()
	self.framesThisSecond = self.framesThisSecond + 1
	if self.framesThisSecond == 60 then
		self.seconds = self.seconds - 1
		self.framesThisSecond = 0
	end
end

function timer:draw(scaleX,scaleY)
	love.graphics.setColor(255,255,255)
	local fontBuffer = love.graphics.getFont()
	love.graphics.setFont(font)
	local fontScaleX = 50/font:getWidth(self.seconds)
	local fontScaleY = 50/font:getHeight(self.seconds)
	love.graphics.print(self.seconds,self.x*scaleX,self.y*scaleY,0,fontScaleX,fontScaleY)
	love.graphics.setFont(fontBuffer)
end

return timer
