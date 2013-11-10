
local Room = require "room"
local Map = require "map"

local Generator = {}

local function dist2(x1,y1,x2,y2)
	local dx, dy = x1-x2, y1-y2
	return dx*dx+dy*dy
end

local function gabriel(verticies)
	coroutine.yield()
	for i=2,#verticies do
		for j=1,i-1 do
			local p1x, p1y = verticies[i]:center()
			local p2x, p2y = verticies[j]:center()
			
			local midx, midy = (p1x+p2x)/2, (p1y+p2y)/2
			local r2 = dist2(midx, midy, p1x, p1y)
			
			local is_neighbor = true
			for k=1,#verticies do
				if k ~= i and k ~= j then
					local p3x, p3y = verticies[k]:center()
					if dist2(midx, midy, p3x, p3y) <= r2 then
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

local function relneighbor(verticies)
	coroutine.yield()
	for i=2,#verticies do
		for j=1,i-1 do
			local p1x, p1y = verticies[i]:center()
			local p2x, p2y = verticies[j]:center()
			local r = dist2(p1x, p1y, p2x, p2y)
			
			local is_neighbor = true
			for k=1,#verticies do
				if k ~= i and k ~= j then
					local p3x, p3y = verticies[k]:center()
					if dist2(p3x, p3y, p1x, p1y) < r and dist2(p3x, p3y, p2x, p2y) < r then
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
		
		-- Generate graph
		local graphgen = coroutine.wrap(relneighbor)
		graphgen(map.rooms)
		for p1, p2 in graphgen do
			p1.adjacent[#p1.adjacent+1] = p2
			p1.adjacent[p2] = true
			
			p2.adjacent[#p2.adjacent+1] = p1
			p2.adjacent[p1] = true
			coroutine.yield()
		end
	end)
end

return Generator
