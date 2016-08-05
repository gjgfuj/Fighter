local inputHandler = {}

--inner class input
input = {}
setmetatable(input,input)

function input:__index(k)
	return rawget(index,k)
end

function input:__call(v)
	local nt = {value = v,timer = 60, active = true}
	setmetatable(nt,input)
	return nt
end

print(input)
linkedList = require "linkedList"

inputHandlers = {} --a complete list of active inputHandlers
setmetatable(inputHandler,inputHandler)

function inputHandler:__index(k)
	return rawget(inputHandler,k)
end

function inputHandler:__call(dv,mp)
	nt = {mapping = mp, device = dv, inputList = linkedList(), reverseMapping = {}, held = {}, lastHat = 'c'} --inputList is a first-in-first-out structure recording inputs
	setmetatable(nt,inputHandler)
	table.insert(inputHandlers,nt) --put the new instance into the list	
	for k,v in pairs(nt.mapping) do
		nt.reverseMapping[v] = k
	end
	return nt
end

function inputHandler:update()
	for inp in listIterator(self.inputList) do
		assert(inp.timer >= 0,"inp.timer is: "..inp.timer)
		inp.timer = inp.timer -1
		if inp.timer <= 0 then self.inputList:dropFrom(inp) end --drop all inputs that have been in the list for more than a second
	end
end

function inputHandler:requestInputs(patterns)
	local inp = self.inputList:getFirst()
	if inp and inp.active then 
		inp.active = false
		return self.mapping[inp.value] 
	else return nil end
end

function inputHandler:isHeld(input)
	return self.held[input]
end

function love.gamepadpressed(joystick, button)
	for k,v in ipairs(inputHandlers) do
		if(v.device == joystick) then 
			if string.find(button, "^dp") then --recognize whether the input is a dpad input
				local hatValue = joystick:getHat(1)
				if hatValue ~= v.inputList:getFirst() then v.inputList:add(input(hatValue)) end--avoid adding the same hatch value twice
				if v.mapping[hatValue] then v.held[v.mapping[hatValue]] = true end
				v.lastHat = hatValue
			else
				v.inputList:add(input(button))
				if v.mapping[button] then v.held[v.mapping[button]] = true end
			end
		end
	end
end

function love.gamepadreleased(joystick, button)
	for k,v in ipairs(inputHandlers) do
		if(v.device == joystick) then
			if string.find(button, "^dp") then
				print(lastHat)
				if v.mapping[v.lastHat] then v.held[v.mapping[v.lastHat]] = false end
			else
				if v.mapping[button] then v.held[v.mapping[button]] = false end
			end
		end
	end
end


return inputHandler