local healthBar = {}

setmetatable(healthBar,healthBar)

function healthBar:__call(c1,x,y,side)
	local nt = {c1 = c1,x = x,y = y,maxHealth = c1.health,side = side}
	setmetatable(nt,{__index = healthBar})
	registerObserver(nt,"damageReceived")
	nt.scaleFactor = 220/nt.c1.health
	return nt
end

function healthBar:update()
end

function healthBar:draw(scaleX,scaleY)
	love.graphics.setColor(0,255,0)
	if self.c1.health > 0 then
		if self.side == "left" then
			local effectiveX = (self.x+(self.maxHealth-self.c1.health)*self.scaleFactor)*scaleX
			love.graphics.rectangle("fill",effectiveX,self.y*scaleY,self.c1.health*scaleX*self.scaleFactor,25*scaleY)
		else
			love.graphics.rectangle("fill",self.x*scaleX,self.y*scaleY,self.c1.health*scaleX*self.scaleFactor,25*scaleY)
		end
	end
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("line",self.x*scaleX-1,(self.y*scaleY)-1,self.maxHealth*self.scaleFactor*scaleX+2,25*scaleY+2)
end

function healthBar:notify(event,a,b)
end

return healthBar
