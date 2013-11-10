
local Room = require "room"
local Map = require "map"

local Generator = {}

function Generator.generate(w,h)
	local map = Map(w,h)
	return map, coroutine.create(function()
		local prevroom = nil
		for y=0,map.h-1 do
			for i=1,4 do
				local room
				local c = 0
				repeat
					local w, h = math.random(2,5), math.random(2)
					local x, y = math.random(0,map.w-1-w), y
					
					room = Room(x,y,0,w,h)
					for _, other in ipairs(map.rooms) do
						if room:intersects(other) then
							room = nil
							break
						end
					end
					c = c + 1
				until room or c > 1000
				
				if room then
					map.rooms[#map.rooms+1] = room
					room.node = {prevroom}
					prevroom = room
				end
				coroutine.yield()
			end
		end
	end)
end

return Generator
