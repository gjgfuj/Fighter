local rect = require("rect")
local char = {}
setmetatable(char,char)
function char:__index(key)
	return rawget(char,key)
end
function char:__call()
	c = {"hurtboxes" = {}}
	setmetatable(c,char)
	return c
end
function char:addHurtbox(h)
	table.insert(self.hurtboxes,h)
end
local hurtbox = {}
setmetatable(hurtbox,hurtbox)
hurtbox.__index = rect
function hurtbox:__call(x,y,width,height)
	return rect(x,y,width,height)
end 
char.hurtbox = hurtbox
return char