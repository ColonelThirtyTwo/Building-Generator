
local Room = require "room"
local Map = require "map"

local Generator = {}

local function gabriel(verticies)
	coroutine.yield()
	for i=2,#verticies do
		for j=1,i-1 do
			local p1, p2 = verticies[i], verticies[j]
			local midx, midy = (p1.x+p2.x)/2, (p1.y+p2.y)/2
			local r2
			do
				local dx, dy = (p1.x-p2.x)/2, (p1.y-p2.y)/2
				r2 = dx*dx+dy*dy
			end
			
			local is_neighbor = true
			for k=1,#verticies do
				if k ~= i and k ~= j then
					local p3 = verticies[k]
					local d2
					do
						local dx, dy = midx-p3.x, midy-p3.y
						d2 = dx*dx+dy*dy
					end
					if d2 <= r2 then
						is_neighbor = false
						break
					end
				end
			end
			
			if is_neighbor then
				coroutine.yield(verticies[i], verticies[j])
			end
		end
	end
end

function Generator.generate(w,h)
	local map = Map(w,h)
	return map, coroutine.create(function()
		-- Generate rooms
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
				end
				coroutine.yield()
			end
		end
		
		for _,room in ipairs(map.rooms) do
			room.adjacent = {}
			coroutine.yield(0.5)
		end
		
		-- Generate gabriel graph
		local gabriel = coroutine.wrap(gabriel)
		gabriel(map.rooms)
		for p1, p2 in gabriel do
			p1.adjacent[#p1.adjacent+1] = p2
			p1.adjacent[p2] = true
			
			p2.adjacent[#p2.adjacent+1] = p1
			p2.adjacent[p1] = true
			coroutine.yield()
		end
	end)
end

return Generator
