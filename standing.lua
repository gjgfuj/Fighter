local standing = {}
setmetatable(standing,standing)

function standing:__index(key)
	return rawget(standing,key)
end

function standing:__call(character1, character2)--character one is assumed to be the character owning this state
	nt = {["c1"] = character1, ["c2"] = character2}
	setmetatable(nt,standing)
	return nt
end

function standing:handleInput(inputs)
		if inputs['f'] then 
			self.c1.state = attack(self.c1,self.c2,5,3,10,{rect(162+self.c1.x,90+self.c1.y,110,57)}) 
			return 
		end
		if inputs['a'] and not inputs['d'] then
				self.c1:move(-500*1/60,0,self.c2)  -- horizontal movement
		elseif inputs['d'] and not inputs['a'] then
				self.c1:move(500*1/60,0,self.c2)  -- horizontal movement
		end
end

function standing:update()
	--probably where the standing/walking animation would be played
end

return standing