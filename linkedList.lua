local linkedList = {}
setmetatable(linkedList,linkedList)

function linkedList:__index(k)
	return rawget(linkedList,k)
end

function linkedList:__call()
	nt = {}
	setmetatable(nt,linkedList)
	return nt
end

function linkedList:add(element)
	newNode = linkedList.node(element)
	newNode.nxt = self.first
	self.first = newNode
end

function linkedList:dropFrom(element)
	if self.first.value == element then 
		self.first = nil
		return
	elseif self.first then 
		local current = self.first
		while(true) do
			if current and current.nxt and current.nxt.value == element then
				current.nxt = nil
				return
			elseif not current then
				return
			else
				current = current.nxt
			end
		end
	end
end

function linkedList:getFirst()
	if self.first then return self.first.value else return nil end
end

function listIterator(list)
	local current = list.first
	return function ()
		if current then
			local buffer = current
			current = current.nxt
			return buffer.value
		else return nil end
	end
end

--inner class node
local node = {}
setmetatable(node,node)

function node:__index(k)
	return rawget(node,k)
end

function node:__call(value)
	nt = {value = value, nxt = nil}
	setmetatable (nt,node)
	return nt
end

linkedList.node = node

return linkedList