rect = {}
setmetatable(rect,rect)
function rect:__index(key)
	return rawget(rect,key)
end
function rect:collide(other)
	if (other.x >= self.x and other.x <= self.endx) or (other.endx >= self.x and other.endx <= self.endx) then
		if (other.y >= self.y and other.y <= self.endy) or (other.endy >= self.y and other.endy <= self.endy) then
			return true
		end
	end
	return false
end
function rect:__call(x,y,width,height)
	nt = {x=x,y=y,width=width,height=height,endx=x+width,endy=y+height}
	setmetatable(nt,rect)
	return nt
end
return rect