local events = {} --two-dimensional array holding events and their corresponding listeners

function distributeEvents(event,a,b,c,d,e)
		for k,v in pairs(events) do
			if k == event then
				for k2,v2 in ipairs(v) do
					v2:notify(event,a,b,c,d,e)
				end
			end
		end
end
function registerObserver(observer,event)
	--first make sure that a table corresponding to the event exists
	if not events[event] then events[event] = {} end
	table.insert(events[event],observer)
end

