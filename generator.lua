
local Room = require "room"

local Generator = {}

function Generator.generate(W,H)
	local rooms = {}
	return rooms, coroutine.create(function()
		for i=1,4 do
			local x, y = math.random(0,W-1), 0
			local w,h = math.random(3,10), math.random(2)
			
			local room = Room(x,y,0,w,h)
			rooms[#rooms+1] = room
			coroutine.yield()
		end
	end)
end

return Generator
