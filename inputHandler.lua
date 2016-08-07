local inputHandler = {}

local inputHandlers = {} --a complete list of active inputHandlers
setmetatable(inputHandler,inputHandler)

local function splitString(str,seperator)-- takes a string and returns a table of parts
	local result = {}
	for part in string.gmatch(str, "([^"..seperator.."]+)") do
		table.insert(result,part)
	end
	return result
end

local function compare(inp1,inp2)--takes care of symbols with multiple meanings
	if inp1 == 'p' then 
		return inp2 ==  "LP" or inp2 == "MP" or inp2 == "HP"
	elseif inp1 == 'k' then 
		return inp2 == "LK" or inp2 == "MK" or inp2 == "HK"
	else 
		return inp1 == inp2 
	end
end

function findPattern(input,pattern)--matches a single pattern to input
	local patternIndex = 2
	local patternBeginning
	local wildcardSkips = 0 -- important for prioritizing
	for i=#input,1,-1 do
		if compare(pattern[1],input[i].value) then
			patternBeginning = i
			break
		end
	end
	if patternBeginning then 
		for i = patternBeginning-1,1,-1 do
			if pattern[patternIndex] == '*' then
				if compare(pattern[patternIndex+1],input[i].value) then 
					patternIndex = patternIndex+2
				else
					wildcardSkips = wildcardSkips +1
				end
			else
				if compare(pattern[patternIndex],input[i].value) then
					patternIndex = patternIndex+1
				else 
					return nil
				end
			end
			if patternIndex >= #pattern then
				return patternBeginning,wildcardSkips
			end
		end
	end
	return nil
end

function inputHandler:patternRecognition(patterns)--returns the pattern with the highest priority,or nil if none match
	local currentPattern
	local currentPatternStart
	local wildcardSkips
	
	for k,pattern in ipairs(patterns) do
		local parts = splitString(pattern,",")
		for i = 1,(#parts*2)-1,2 do
			table.insert(parts,i+1,'*')
		end
		pIndex,skips = findPattern(self.inputList,parts)
		if pIndex and self.inputList[pIndex].timer == 60 then 
			for k,v in ipairs(self.inputList) do print(k,v.value) end 
			print("-----------")
			print(pattern,skips,#pattern,pIndex)
			print("-----------")
		end
		
		if pIndex and self.inputList[pIndex].timer == 60 and not(currentPattern and (currentPatternStart<pIndex or wildcardSkips <= skips or #currentPattern > #pattern)) then
			currentPattern = pattern
			currentPatternStart = pIndex
			wildcardSkips = skips
		end
	end
	if currentPattern then print("NEWFRAME") end
	return currentPattern
end

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
		if v.value == input then index = k end
	end
	local result = self.inputList[index]
	return result and result.timer == 60
end


function inputHandler:isHeld(input)
	return self.held[input]
end

function love.gamepadpressed(joystick, button)
	for k,v in ipairs(inputHandlers) do --since the callback function can't be called on an object we need to manually check if it is relevant to any instance of inputHandler
		if(v.device == joystick) then --check if the device registered with the input handler is this specific joystick 
			if not string.find(button, "^dp") then --recognize whether the input is a dpad input
				if v.mapping[button] then 
					table.insert(v.inputList,inputHandler.input(v.mapping[button]))
					v.held[v.mapping[button]] = true
				end
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
			if v.mapping[direction] then table.insert(v.inputList,inputHandler.input(v.mapping[direction])) end
			if v.mapping[v.lastHat] then v.held[v.mapping[v.lastHat]] = false end
			v.lastHat = v.mapping[direction]
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
