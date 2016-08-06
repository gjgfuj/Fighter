local inputHandler = {}

local inputHandlers = {} --a complete list of active inputHandlers
setmetatable(inputHandler,inputHandler)

function inputHandler:__index(k)
	return rawget(inputHandler,k)
end

function inputHandler:__call(dv,mp)
	nt = {mapping = mp, device = dv, inputList = {}, reverseMapping = {}, held = {}, __lastHat = 'c'} --inputList is a first-in-first-out structure recording inputs
	setmetatable(nt,inputHandler)
	table.insert(inputHandlers,nt) --put the new instance into the list	
	for k,v in pairs(nt.mapping) do
		nt.reverseMapping[v] = k
	end
	return nt
end

function inputHandler:update()
	for k,inp in ipairs(self.inputList) do
		assert(inp.timer >= 0,"inp.timer is: "..inp.timer)
		inp.timer = inp.timer -1
		if inp.timer <= 0 then table.remove(self.inputList,k) end
	end
end

function inputHandler:isTapped(input,patterns)
	local inp = self.reverseMapping[input]
	local index
	for k,v in ipairs(self.inputList) do
		if v.value == inp then index = k end
	end
	print(index)
	local result = self.inputList[index]
	if result then print (result.value..", "..result.timer) end
	if result then print(result.timer) end
	return result and result.timer == 60
end


function inputHandler:isHeld(input)
	return self.held[input]
end

function love.gamepadpressed(joystick, button)
	for k,v in ipairs(inputHandlers) do --since the callback function can't be called on an object we need to manually check if it is relevant to any instance of inputHandler
		if(v.device == joystick) then --check if the device registered with the input handler is this specific joystick 
			if not string.find(button, "^dp") then --recognize whether the input is a dpad input
				table.insert(v.inputList,inputHandler.input(button))
				if v.mapping[button] then v.held[v.mapping[button]] = true end
			end
		end
	end
end

function love.gamepadreleased(joystick, button)
	for k,v in ipairs(inputHandlers) do
		if(v.device == joystick) then
			if not string.find(button, "^dp") then
				if v.mapping[button] then v.held[v.mapping[button]] = false end
			end
		end
	end
end

function love.joystickhat(joystick, hat,direction)
	for k,v in ipairs(inputHandlers) do
		if(v.device == joystick) then 
			table.insert(v.inputList,inputHandler.input(direction))
			if v.mapping[v.lastHat] then v.held[v.mapping[v.lastHat]] = false end
			v.lastHat = direction
			if v.mapping[direction] then v.held[v.mapping[direction]] = true end
		end
	end
end

local input = {}
setmetatable(input,input)
--
function input:__index(k)
	return rawget(index,k)
end

function input:__call(v)
	local nt = {value = v,timer = 60, active = true}
	setmetatable(nt,input)
	return nt
end

inputHandler.input = input

return inputHandler