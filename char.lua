local rect = require("rect")
local char = {}
setmetatable(char,char)
function char:__index(key)
	return rawget(char,key)
end
function char:__call()
	c = {}
	setmetatable(c,char)
	return c
end
local hitbox = {}
setmetatable(hitbox,hitbox)
hitbox.__index = rect
char.hitbox = hitbox
return char