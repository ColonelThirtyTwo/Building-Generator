
local Room = require "room"
local Map = require "map"

local Generator = {}

local function dist2(x1,y1,x2,y2)
	local dx, dy = x1-x2, y1-y2
	return dx*dx+dy*dy
end

local function removeVal(tbl, val)
	for i=1,#tbl do
		if tbl[i] == val then
			table.remove(tbl, i)
			return true
		end
	end
	return false
end

local function center(self)
	return self.x + 0.5, self.y + 0.5
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
		
		local function intersects(room)
			for _,other in ipairs(map.rooms) do
				if room ~= other and room:intersects(other) then
					return true
				end
			end
			return false
		end
		
		-- Generate rooms
		for i=1,25 do
			local room
			local c = 0
			repeat
				local w,h
				if math.random() <= 0.3 then
					w, h = 1, math.random(2,4)
				else
					w, h = math.random(2,5), 1
				end
				
				local x, y = math.random(0,map.w-1-w), math.random(0, map.h-1-h)
				
				room = Room(x,y,0,w,h)
				for _, other in ipairs(map.rooms) do
					if room:intersects(other) then
						room = nil
						break
					end
				end
				c = c + 1
			until room or c > 100
			
			if room then
				map.rooms[#map.rooms+1] = room
			end
			coroutine.yield()
		end
		
		-- Apply gravity
		table.sort(map.rooms, function(a,b) return a.y < b.y end)
		for _,room in ipairs(map.rooms) do
			repeat
				room.y = room.y - 1
			until room.y < 0 or intersects(room)
			room.y = room.y + 1
			coroutine.yield()
		end
		
		-- Generate nodes
		for _,room in ipairs(map.rooms) do
			room.nodes = room.nodes or {}
			for x=room.x,room.x+room.w-1 do
				for y=room.y,room.y+room.h-1 do
					local n = {
						x = x,
						y = y,
						room = room,
						adjacent = {},
						center = center,
					}
					map.nodes[#map.nodes+1] = n
					room.nodes[#room.nodes+1] = n
					coroutine.yield(0.1)
				end
			end
		end
		
		-- Generate graph
		local graphgen = coroutine.wrap(relneighbor)
		graphgen(map.nodes)
		for p1, p2 in graphgen do
			if p1.room ~= p2.room then
				p1.adjacent[#p1.adjacent+1] = p2
				p1.adjacent[p2] = true
				
				p2.adjacent[#p2.adjacent+1] = p1
				p2.adjacent[p1] = true
				coroutine.yield(0.2)
			end
		end
		
		-- Mark nodes for deletion
		for i=#map.nodes,1,-1 do
			local node = map.nodes[i]
			if #node.adjacent == 0 then
				table.remove(map.nodes, i)
				assert(removeVal(node.room.nodes, node))
				node.room.nodes[node] = nil
				coroutine.yield(0.2)
			end
		end
		
	end)
end

return Generator
