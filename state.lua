local state = {}

setmetatable(state,state)

function state:__index(key)
	return rawget(state,key)
end

--TODO: optimize by caching splitString results somewhere,maybe on construction
function state:checkInputs()
	pattern = self.c1.handler:patternRecognition(self.patterns)
	if pattern then
		self.c1.state = self.patternStates[pattern]:copy()
		return true
	end
	for input,result in pairs(self.fpcombinations) do
		if self.c1.handler.isTapped(unpack(splitString(input,','))) then
			self.c1.state = result:copy()
			return true
		end 
	end
	for input,result in pairs(self.combinations) do
		if self.c1.handler:buttonCombination(unpack(splitString(input,','))) then
			self.c1.state = result:copy()
			return true
		end
	end
	for input,result in pairs(self.buttons) do
		if self.c1.handler:isTapped(input) then
			self.c1.state = result:copy()
			return true
		end
	end
	return false
end

function state:copy()
	print("SUPER")
	local nt = {}
	for k,v in pairs(self) do
		nt[k] = v
	end
	setmetatable(nt,getmetatable(self))
	return nt
end

return state
