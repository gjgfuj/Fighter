local gamestate = require "gamestate"

local startGamestate = {}

setmetatable(startGamestate,{__index = gamestate})

local rotation = 0

function startGamestate.load()
end

function startGamestate.update()
	rotation = rotation+math.pi*1/60
end

function startGamestate.draw()
	local width,height = love.graphics.getDimensions()
	love.graphics.scale(width/640,height/360)

	love.graphics.push()
		love.graphics.translate(245,145)
		love.graphics.rotate(rotation)
		love.graphics.translate(-245,-145)
		love.graphics.setColor(255,0,0)
		love.graphics.rectangle("fill",220,120,50,50)
	love.graphics.pop()

	love.graphics.setColor(255,255,255)
	local text =  "Press ENTER"
	love.graphics.printf(text,0,173,640,'center')
end

function startGamestate.keypressed(key)
	if key == "return" then
		switchGamestate(require "inFightGamestate")
	end
end

return startGamestate
