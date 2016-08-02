rect = {}
setmetatable(rect,rect)
function rect:__index(key)
	return rawget(rect,key)
end
function rect:collide(other)
	return self:__basecollide(other) or other:__basecollide(self)
end
function rect:__basecollide(other)
    --this is a workaround right now and will definitely be included in the clean up
    local endx = self.x+self.width
	local endy = self.y+self.height
	
	local otherEndx = other.x+other.width
	local otherEndy = other.y+other.height
	
	if (other.x >= self.x and other.x <= endx) or (otherEndx >= self.x and otherEndx <= endx) or (other.x <= self.x and otherEndx >= self.x) then
		if (other.y >= self.y and other.y <= endy) or (otherEndy >= self.y and otherEndy <= endy) or (other.y <= self.y and otherEndy >= self.y) then
			return true
		end
	end
	return false
end
function rect:__call(x,y,width,height)
	nt = {x=x,y=y,width=width,height=height}
	setmetatable(nt,self)
	return nt
end
return rect