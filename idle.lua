local idle = {}
setmetatable(idle,idle)

function idle:__index(key)
	return rawget(idle,key)
end

function idle:__call(character1, character2)--character one is assumed to be the character owning this state
	nt = {["c1"] = character1, ["c2"] = character2}
    setmetatable(nt,idle)
	return nt
end

function idle:handleInput(inputs)
		if inputs['f'] then 
			c1.state = attack(c1,c2,5,3,10,{rect(162+c1.x,90+c1.y,159,57)}) 
			return 
		end
		if inputs['a'] and not inputs['d'] then
		    local leftCollision = false
			local distance = 500*(1/60)
			for k,v in ipairs(self.c1.collisionboxes) do
				for k2,v2 in ipairs (self.c2.collisionboxes) do
					if(v:collide(v2) and v2.x <= v.x) then 
						leftCollision = true
						break
					end
				end
			end
			if(not leftCollision) then
				self.c1:move(-distance,0)  -- horizontal movement
			end		
		elseif inputs['d'] and not inputs['a'] then
		    local rightCollision = false
			local distance = speed*(1/60)
			for k,v in ipairs(self.c1.collisionboxes) do
			    print(k..","..v.x..","..v.y..","..v.width..","..v.height)
				for k2,v2 in ipairs (self.c2.collisionboxes) do
					print(k2..","..v2.x..","..v2.y..","..v2.width..","..v2.height)
					print(self.c1.collisionboxes[1]:collide(self.c2.collisionboxes[1]))
					if(v:collide(v2) and v2.x + v2.width >= v.x+ v.width) then 
						rightCollision = true
						break
					end
				end
			end
			if(not rightCollision) then
				self.c1:move(distance,0)  -- horizontal movement
			end
		end
end

function idle:update()
	--probably where the idle/walking animation would be played
end

return idle