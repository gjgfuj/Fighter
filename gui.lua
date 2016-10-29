local instance

local gui = {}

setmetatable(gui,gui)

function gui:__call()
	if instance then return instance
	else
		local nt = {elements = {}}
		setmetatable(nt,{__index = gui})
		return nt
	end
end

function gui:addElement(element)
	table.insert(self.elements,element)
end

function gui:update()
	for k,v in ipairs(self.elements) do
		v:update()
	end
end

function gui:draw(scaleX,scaleY)
	for k,v in ipairs(self.elements) do
		v:draw(scaleX,scaleY)
	end
end


return gui
