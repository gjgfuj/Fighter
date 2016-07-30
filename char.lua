local rect = require("rect")
local char = {}
setmetatable(char,char)
function char:__index(key)
	return rawget(char,key)
end
function char:__call(nx,ny)
	c = {["x"] = nx,["y"] = ny,["hurtboxes"] = {}}
	setmetatable(c,char)
	return c
end
function char:addHurtbox(hx,hy,width,height)
	table.insert(self.hurtboxes,char.hurtbox(self.x+hx,self.y+hy,width,height)) -- place the hurtboxes in the relative grid
	-- This makes initializing hurtboxes consistent regardless of character position
end

function char:move(xVel,yVel)
    --change character coordinates
	self.x = self.x+xVel
	self.y = self.y+yVel
	--move all Hurtboxes
	for k,v in ipairs(self.hurtboxes) do
	v.x = v.x+xVel
	v.y = v.y+yVel
	end
end

function char:draw()
    love.graphics.setColor(255,255,255) -- set color to white
    love.graphics.print("x:"..self.x.." y:"..self.y,self.x+10,self.y-15)
    if(self.image) then love.graphics.draw(self.image,self.x,self.y) end  --draw the sprite if available
	love.graphics.setColor(255,0,0)--set color to red
	for k,v in ipairs(self.hurtboxes) do love.graphics.rectangle("line",v.x,v.y,v.width,v.height) end -- draw hurtboxes for debugging
end

--inner class hurtbox
local hurtbox = {}
setmetatable(hurtbox,hurtbox)
hurtbox.__index = rect
function hurtbox:__call(x,y,width,height)
	return rect(x,y,width,height)
end 
char.hurtbox = hurtbox
return char