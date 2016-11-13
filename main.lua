local activeGameState = require "startGamestate"

function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
	end
 
	if love.load then love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt
	local lastFrame = 0
	-- Main loop time.
	while true do
		--If it is time for another tick calculate the tick
		if(love.timer.getTime()-lastFrame >= 1/60) then
			lastFrame = love.timer.getTime()
			if love.timer then
				love.timer.step()
				dt = love.timer.getDelta()
			end
			if love.event then
				love.event.pump()
				for name, a,b,c,d,e,f in love.event.poll() do
					if name == "quit" then
						if not love.quit or not love.quit() then
							return a
						end
					end
					love.handlers[name](a,b,c,d,e,f)
				end
			end
	 
			-- Call update and draw
			if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
	 
			if love.graphics and love.graphics.isActive() then
				love.graphics.clear(love.graphics.getBackgroundColor())
				love.graphics.origin()
				if love.draw then love.draw() end
				love.graphics.present()
			end
		end
	end
end

function love.load()
	love.graphics.setDefaultFilter("nearest","nearest",1)
	love.graphics.setBackgroundColor(0,0,255)
	love.window.setMode(640,360,{["fullscreen"] = true,["fullscreentype"]= "desktop", ["vsync"] = true})

	activeGameState.load()
end

function love.update()
	activeGameState.update()
end

function love.draw()
	activeGameState.draw()
end 

function switchGamestate(gamestate)
	love.graphics.origin()
	activeGameState = gamestate
	activeGameState.load()
end

--forward event handlers
function love.keypressed(key)
	activeGameState.keypressed(key)
end

function love.keyreleased(key)
	activeGameState.keyreleased(key)
end

function love.gampadpressed(joystick,button)
	activeGameState.gamepadpressed(joystick,button)
end

function love.gamepadreleased(joystick,button)
	activeGameState.gamepadpressed(joystick,button)
end

function love.joystickhat(joystick,hat,direction)
	activeGameState.joystickhat(joystick,hat,direction)
end

function love.gamepadaxis(joystick,axis,value)
	activeGameState.gamepadaxis(joystick,axis,value)
end
