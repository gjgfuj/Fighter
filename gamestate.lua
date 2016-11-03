local gamestate = {}

setmetatable(gamestate,gamestate)

function gamestate:__index(key)
	print("WARNING: "..key.." isn't implemented in this Gamestate")
	return function() end
end

return gamestate
