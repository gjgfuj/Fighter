local state = {}

setmetatable(state,state)

function state:__index(key)
	return rawget(state,key)
end

--TODO: optimize by caching splitString results somewhere,maybe on construction
function state:checkInputs()
	if self.__base.inputsRight ~= self.c1.lookingRight then print "TURNING" self:turnInputs() end
	pattern = self.c1.handler:patternRecognition(self.patterns)
	if pattern then
		self.c1:setState(self.patternStates[pattern]:copy())
		return true
	end
	for input,result in pairs(self.fpcombinations) do
		if self.c1.handler.isTapped(unpack(splitString(input,','))) then
			self.c1:setState(result:copy())
			return true
		end 
	end
	for input,result in pairs(self.combinations) do
		if self.c1.handler:buttonCombination(unpack(splitString(input,','))) then
			self.c1:setState(result:copy())
			return true
		end
	end
	for input,result in pairs(self.buttons) do
		if self.c1.handler:isTapped(input) then
			self.c1:setState(result:copy())
			return true
		end
	end
	return false
end


function state:addHurtbox(hx,hy,width,height)
	if not self.hurtboxValues then self.hurtboxValues = {} end
	table.insert(self.hurtboxValues,{hx,hy,width,height}) -- place the hurtboxes in the relative grid
	-- This makes initializing hurtboxes consistent regardless of character position
end

function state:addCollisionbox(hx,hy,width,height)
	if not self.collisionboxValues then self.collisionboxValues = {} end
	table.insert(self.collisionboxValues,{hx,hy,width,height}) -- place the hurtboxes in the relative grid
	-- This makes initializing hurtboxes consistent regardless of character position
end

local function __copy(self)
	local nt = {}
	for k,v in pairs(self) do
		self[k] = v
	end
	setmetatable(nt,getmetatable(self))
	return nt
end

function state:copy()
	local nt = {__base = self}
	for k,v in pairs(self) do
		nt[k] = v
	end
	setmetatable(nt,getmetatable(self))
	nt.hurtboxes = {}
	if nt.hurtboxValues then for k,v in ipairs(nt.hurtboxValues) do 
		table.insert(nt.hurtboxes,rect(v[1]+nt.c1.x,v[2]+nt.c1.y,v[3],v[4]))
	end end
	nt.collisionboxes = {}
	if nt.collisionboxValues then for k,v in ipairs(nt.collisionboxValues) do
		table.insert(nt.collisionboxes,rect(v[1]+nt.c1.x,v[2]+nt.c1.y,v[3],v[4]))
	end end
	return nt
end

local function turnInput(input)
	input = input:gsub('l','#')
	input = input:gsub('r','~')
	input = input:gsub('#','r')
	return input:gsub('~','l')
end

local function turnInputsIn(tableToTurn)
	print(#tableToTurn)
	for k,v in pairs(tableToTurn) do
		local turnedInput = turnInput(k)
		tableToTurn[k] = nil
		tableToTurn[turnedInput] = v
	end
end

function state:turnInputs()
	for k,v in ipairs(self.patterns) do
		local turnedInput = turnInput(v)
		local buffer = self.patternStates[v]
		self.patternStates[v] = nil
		self.patternStates[turnedInput] = buffer
		self.patterns[k] = turnedInput
	end
	print(self.combinations)
	turnInputsIn(self.combinations)
	self.__base.inputsRight = not self.__base.inputsRight
end

return state
