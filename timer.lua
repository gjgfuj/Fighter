local timer = {}

local font = love.graphics.newFont(50)

setmetatable(timer,timer)

function timer:__call(x,y,width,height,seconds)
	local nt = {x = x,y = y,seconds = seconds,framesThisSecond = 0}
	setmetatable(nt,{__index = timer})
	return nt
end

function timer:update()
	self.framesThisSecond = self.framesThisSecond + 1
	if self.framesThisSecond == 60 then --Count ingame-time by frames passed
		self.seconds = self.seconds - 1
		self.framesThisSecond = 0
		if self.seconds <= 0 then startGame() end --TODO replace with evaluation
	end
end

function timer:draw(scaleX,scaleY)
	love.graphics.setColor(255,255,255)
	--Buffer the set font to reset it
	local fontBuffer = love.graphics.getFont()
	love.graphics.setFont(font)
	--Calculate the scale factor to scale the timer to the desired size
	local fontScaleX = 50/font:getWidth(self.seconds)
	local fontScaleY = 50/font:getHeight(self.seconds)
	love.graphics.print(self.seconds,self.x*scaleX,self.y*scaleY,0,fontScaleX,fontScaleY)
	--reset the font
	love.graphics.setFont(fontBuffer)
end

return timer
