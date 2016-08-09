local inputHandler = {}

local inputHandlers = {} --a complete list of active inputHandlers
setmetatable(inputHandler,inputHandler)

local INPUT_PERSISTENCE = 30 -- constant indicating how many frames an input is remembered for input reading

local function invertIpairs(array)
	local i = #array
	return function()
		local buffer = i
		i = i-1
		if array[buffer] then return buffer,array[buffer] else return nil end
	end
end

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
			patternBeginning = i-- first, find where the pattern starts
			break
		end
	end
	if patternBeginning then 
		for i = patternBeginning-1,1,-1 do
			if pattern[patternIndex] == '*' then -- If there is a wildcard check for the following symbol until you find it
				if compare(pattern[patternIndex+1],input[i].value) then 
					patternIndex = patternIndex+2
				else
					wildcardSkips = wildcardSkips +1 --keep track of how many times you had to skip for wildcards, that tells you how likely this one is to be the intended one
				end
			else
				if compare(pattern[patternIndex],input[i].value) then
					patternIndex = patternIndex+1
				else 
					return nil-- there's no wildcard so there can't be skips
				end
			end
			if patternIndex >= #pattern then -- if the patternIndex is outside the pattern array the entire pattern has been found
				return patternBeginning,wildcardSkips
			end
		end
	end
	return nil -- if the execution gets here the function must have run through the entire input without finding the pattern
end

function inputHandler:patternRecognition(patterns)--returns the pattern with the highest priority,or nil if none match
	local currentPattern
	local currentPatternStart
	local wildcardSkips
	
	for k,pattern in ipairs(patterns) do
		local parts = splitString(pattern,",")
		for i = 1,(#parts*2)-1,2 do-- put in the wildcards
			table.insert(parts,i+1,'*')
		end
		pIndex,skips = findPattern(self.inputList,parts) -- find the pattern
		--check pattern priotity
		if pIndex and self.inputList[pIndex].timer == INPUT_PERSISTENCE and not(currentPattern and (currentPatternStart<pIndex or wildcardSkips <= skips or #currentPattern > #pattern)) then
			currentPattern = pattern
			currentPatternStart = pIndex
			wildcardSkips = skips
		end
	end
	return currentPattern
end

function inputHandler:__index(k)
	return rawget(inputHandler,k)
end

function inputHandler:__call(dv,mp)
	local nt = {mapping = mp, device = dv, inputList = {}, reverseMapping = {}, held = {}, __lastHat = 'c'} --inputList is a first-in-first-out structure recording inputs
	setmetatable(nt,inputHandler)
	table.insert(inputHandlers,nt) --put the new instance into the list	
	for k,v in pairs(nt.mapping) do
		nt.reverseMapping[v] = k
	end
	return nt
end

function inputHandler:update()
	for k,inp in invertIpairs(self.inputList) do
		assert(inp.timer >= 0,"inp.timer is: "..inp.timer)
		inp.timer = inp.timer -1
		if inp.timer <= 0 then table.remove(self.inputList,k) end
	end
end

function inputHandler:isTapped(input,patterns)
	local index
	for k,v in invertIpairs(self.inputList) do
		if v.value == input then 
			index = k 
			break
		end
	end
	local result = self.inputList[index]
	return result and result.timer == INPUT_PERSISTENCE
end


function inputHandler:isHeld(input)
	return self.held[input]
end

---input: the input to check
--amount: The amount of taps asked
--period: The period of times all taps must have occured in
--The first input found is also required to be 'frame-fresh'
function inputHandler:multiTap(input,amount,period)
	assert (period <= INPUT_PERSISTENCE,"period exceeds input persistence.\n Period: "..period.." Persistence: "..INPUT_PERSISTENCE)
	for k,v in invertIpairs(self.inputList) do
		if v.value == input and v.timer >= INPUT_PERSISTENCE then
			for i = k,k-(amount-1),-1 do
				if(not (self.inputList[i] and self.inputList[i].value == input and self.inputList[i].timer >= INPUT_PERSISTENCE - period)) then
					return false
				end
			end		
			return true
		end
	end
	return false
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
			if v.mapping[v.lastHat] then v.held[v.lastHat] = false end
			v.lastHat = v.mapping[direction] -- we need to remember the last position of the hat so we can reset the held status
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
	local nt = {value = v,timer = INPUT_PERSISTENCE, active = true}
	setmetatable(nt,input)
	return nt
end

inputHandler.input = input

return inputHandler
