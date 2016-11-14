local char = require "char"

local state = {}

setmetatable(state,state)

state.type = "state"
function state:__index(key)
	return rawget(state,key)
end

function state:__call(c1,c2,buttons,combinations,fpcombinations,patternStates)
	local nt = {c1=c1, c2=c2, buttons=buttons, combinations=combinations, fpcombinations = fpcombinations, patternStates=patternStates,inputsRight = true,delay = true}
	nt.hurtboxes = {}
	nt.collisionboxes = {}
	nt.patterns = {}
	if not nt.buttons then nt.buttons = {} end
	if not nt.combinations then nt.combinations = {} end
	if not nt.fpcombinations then nt.fpcombinations = {} end
	if not nt.patternStates then nt.patternStates = {} end
	for k,v in pairs(patternStates) do
		table.insert(nt.patterns,k)
	end
	return nt
end

--Substitutes 'f' and 'b' (forward and back) in input patterns for their effective meaning depending on character orientation
function state:chooseDirectionals(input)
	if self.c1.lookingRight then
		input = input:gsub('f','r')
		input = input:gsub('b','l')
	else
		input = input:gsub('f','l')
		input =  input:gsub('b','l')
	end
	return input
end

function state:unchooseDirectionals(input)
	if self.c1.lookingRight then
		input = input:gsub('r','f')
		input =  input:gsub('l','b')
	else
		input = input:gsub('l','f')
		input = input:gsub('r','b')
	end
	return input
end

--TODO: optimize by caching splitString results somewhere,maybe on construction
function state:checkInputs()
	local buffer = {}
	for k,v in ipairs(self.patterns) do
		buffer[k] = self:chooseDirectionals(v)
	end
	pattern = self.c1.handler:patternRecognition(buffer)
	if pattern then
		pattern = self:unchooseDirectionals(pattern)
		self.c1:setState(self.patternStates[pattern])
		return true
	end
	for input,result in pairs(self.fpcombinations) do

		if self.c1.handler:isTapped(unpack(splitString(self:chooseDirectionals(input),','))) then
			self.c1:setState(result)
			return true
		end 
	end
	for input,result in pairs(self.combinations) do
		if self.c1.handler:buttonCombination(unpack(splitString(self:chooseDirectionals(input),','))) then
			self.c1:setState(result)
			return true
		end
	end
	for input,result in pairs(self.buttons) do
		if self.c1.handler:isTapped(self:chooseDirectionals(input)) then
			self.c1:setState(result)
			return true
		end
	end
	return false
end


function state:addHurtbox(hx,hy,width,height,flags)
	if not self.hurtboxValues then self.hurtboxValues = {} end
	table.insert(self.hurtboxValues,{hx,hy,width,height,flags}) -- place the hurtboxes in the relative grid
	-- This makes initializing hurtboxes consistent regardless of character position
end

function state:addCollisionbox(hx,hy,width,height)
	if not self.collisionboxValues then self.collisionboxValues = {} end
	table.insert(self.collisionboxValues,{hx,hy,width,height}) -- place the collisionboxes in the relative grid
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
	local nt = {}
	for k,v in pairs(self) do
		nt[k] = v
	end
	setmetatable(nt,getmetatable(self))
	nt.hurtboxes = {}
	if nt.hurtboxValues then for k,v in ipairs(nt.hurtboxValues) do 
		table.insert(nt.hurtboxes,char.hurtbox(v[1]+nt.c1.x,v[2]+nt.c1.y,v[3],v[4],v[5]))
	end end
	nt.collisionboxes = {}
	if nt.collisionboxValues then for k,v in ipairs(nt.collisionboxValues) do
		table.insert(nt.collisionboxes,rect(v[1]+nt.c1.x,v[2]+nt.c1.y,v[3],v[4]))
	end end
	return nt
end

function state:supplyBoxes()
	return self.hurtboxValues,self.collisionboxValues 
end

function state:handleHit(damage,chip,hitEffect) -- the default implementation assumes that the character wasn't able to block
	distributeEvents("directHit",self.c2,self.c1,damage)
	self.c1:doDamage(damage)
	self.c1:queueState(hitEffect)
end

function state:getBottom()
	local maximum
	for k,v in ipairs(self.collisionboxes) do
		if not maximum or v.y + v.height > maximum then
			maximum = v.y + v.height
		end
	end
	return maximum
end

function state:getWidth()
	local max = 0
	for k,v in ipairs(self.collisionboxes) do
		if v.endx > max then 
			max = v.endx
		end
	end
	return math.abs(max-self.c1.x)
end

function state:flipBoxes()
	for k,v in ipairs(self.hurtboxes) do 
		flipBox(v,width,self.c1)
	end
	for k,v in ipairs(self.collisionboxes) do
		flipBox(v,width,self.c1)
	end
	if self.hitboxes then for k,v in ipairs(self.hitboxes) do
		flipBox(v,width,self.c1)
	end end
end

function state:acquireBoxes()
	self.hurtboxValues,self.collisionboxValues = self.c1:supplyBoxes()
end

function state:fallback()
	if self.fallbackState then self.c1:setState(self.fallbackState) else self.c1:setState(self.c1.standing) end
end

function state:setState(toSet)
	self.c1.state = toSet:copy()
end

function state:getCollisionStart()
	local buffer
	for k,v in ipairs(self.collisionboxes) do
		if not buffer or v.x < buffer then
			buffer = v.x
		end
	end
	return buffer
end

function state:init()
end

return state
