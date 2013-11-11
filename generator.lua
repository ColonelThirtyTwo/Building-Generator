
local Room = require "room"
local Map = require "map"

local Generator = {}

local abs = math.abs

local function dist2(x1,y1,z1,x2,y2,z2)
	local dx, dy, dz = x1-x2, y1-y2, z1-z2
	return dx*dx+dy*dy+dz*dz*20
end

--[[local function dist2(x1,y1,z1,x2,y2,z2)
	local dx, dy, dz = x1-x2, y1-y2, z1-z2
	return abs(dx) + abs(dy) + abs(dz) * 20
end]]

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
	return self.x + 0.5, self.y + 0.5, self.z
end
local function drawCenter(self)
	if self.parent then
		return self.x + 0.6, self.y+0.6, self.z
	else
		return self.x + 0.4, self.y+0.4, self.z
	end
end

local function adjacentRooms(node, baseroom, list, visited)
	list = list or {}
	baseroom = baseroom or node.room
	visited = visited or {}
	
	if not visited[node] then
		visited[node] = true
		list[node.room] = true
	
		if node.room == baseroom then
			for _,adjnode in ipairs(node.adjacent) do
				adjacentRooms(adjnode, baseroom, list, visited)
			end
		end
	end
	
	return list, visited
end

local function adjRoomSearch(node, rooms, baseroom, list, visited, prev)
	baseroom = baseroom or node.room
	list = list or {}
	visited = visited or {}
	
	if not visited[node] then
		node.highlight = true
		coroutine.yield()
		
		visited[node] = true
		if node.room == baseroom then
			for _,adjnode in ipairs(node.adjacent) do
				adjRoomSearch(adjnode, rooms, baseroom, list, visited, node)
			end
		elseif rooms[node.room] then
			list[#list+1] = {prev, node}
		end
	end
	return list, visited
end

local function gabriel(verticies)
	coroutine.yield()
	for i=2,#verticies do
		for j=1,i-1 do
			local p1x, p1y, p1z = verticies[i]:center()
			local p2x, p2y, p2z = verticies[j]:center()
			
			local midx, midy, midz = (p1x+p2x)/2, (p1y+p2y)/2, (p1z+p2z)/2
			local r2 = dist2(midx, midy, midz, p1x, p1y, p1z)
			
			local is_neighbor = true
			for k=1,#verticies do
				if k ~= i and k ~= j then
					local p3x, p3y, p3z = verticies[k]:center()
					if dist2(midx, midy, midz, p3x, p3y, p3z) <= r2 then
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
			local p1x, p1y, p1z = verticies[i]:center()
			local p2x, p2y, p2z = verticies[j]:center()
			local r = dist2(p1x, p1y, p1z, p2x, p2y, p2z)
			
			local is_neighbor = true
			for k=1,#verticies do
				if k ~= i and k ~= j then
					local p3x, p3y, p3z = verticies[k]:center()
					if dist2(p3x, p3y, p3z, p1x, p1y, p1z) < r and dist2(p3x, p3y, p3z, p2x, p2y, p2z) < r then
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

function Generator.generate(options)
	local map = Map(options.w,options.h,options.d)
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
		for i=1,options.rooms do
			local room
			local c = 0
			repeat
				room = options.genroom(map)
				for _, other in ipairs(map.rooms) do
					if room:intersects(other) then
						room = nil
						break
					end
				end
				c = c + 1
			until room or c > 100
			
			if room then
				map:addRoom(room)
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
			for x=room.x,room.x+room.w-1 do
				for y=room.y,room.y+room.h-1 do
					local n = {
						x = x,
						y = y,
						z = room.z,
						room = room,
						adjacent = {},
						center = center,
						drawCenter = drawCenter,
					}
					map.nodes[#map.nodes+1] = n
					coroutine.yield(0.5)
				end
			end
		end
		
		-- Generate graph
		local graphgen = coroutine.wrap(relneighbor)
		graphgen(map.nodes)
		for p1, p2 in graphgen do
			p1.adjacent[#p1.adjacent+1] = p2
			p1.adjacent[p2] = true
			
			p2.adjacent[#p2.adjacent+1] = p1
			p2.adjacent[p1] = true
			coroutine.yield()
		end
		
		-- Generate minimum spanning tree
		do
			local tree = map.tree
			do
				local bn = map.nodes[1]
				local n = {
					x = bn.x, y = bn.y, z = bn.z,
					room = bn.room,
					parent = bn,
					adjacent = {},
					center = center,
					drawCenter = drawCenter,
				}
				tree[1] = n
				tree[n.parent] = 1
				coroutine.yield()
			end
			
			while #tree ~= #map.nodes do
				local min_in, min_out, min_d = tree[1], nil, math.huge
				for _,node1 in ipairs(tree) do
					for _,node2 in ipairs(node1.parent.adjacent) do
						if not tree[node2]then
							local d = dist2(node1.x, node1.y, node1.z, node2.x, node2.y, node2.z)
							if node1.room ~= node2.room then d = d + 0.1 end
							if d < min_d then
								min_in = node1
								min_out = node2
								min_d = d
							end
						end
					end
				end
				assert(min_out)
				
				local n = {
					x = min_out.x, y = min_out.y, z = min_out.z,
					room = min_out.room,
					parent = min_out,
					adjacent = {},
					center = offsetCenter,
					drawCenter = drawCenter,
				}
				local i = #tree+1
				tree[i] = n
				tree[n.parent] = i
				
				min_in.adjacent[#min_in.adjacent+1] = n
				min_in.adjacent[n] = true
				n.adjacent[1] = min_in
				n.adjacent[min_in] = true
				coroutine.yield()
			end
		end
		
		-- Randomly re-connect nodes in the tree to form loops
		do
			local num_connections, c = options.loops, 0
			while num_connections > 0 and c < 1000 do
				c = c + 1
				local rand_node = map.tree[math.random(#map.tree)]
				
				-- Get all connectable adjacent rooms and subtract the ones we have already connected to.
				local all_adj_rooms = adjacentRooms(rand_node.parent)
				local connected_adj_rooms = adjacentRooms(rand_node)
				
				for k,_ in pairs(connected_adj_rooms) do
					assert(all_adj_rooms[k])
					all_adj_rooms[k] = nil
				end
				
				if next(all_adj_rooms) then
					-- Get all potential connections to the unconnected adjacent room
					local connections, visited = adjRoomSearch(rand_node.parent, all_adj_rooms)
					assert(#connections > 0)
					
					for k,_ in pairs(visited) do k.highlight = nil end
					
					local connection = connections[math.random(#connections)]
					assert(connection)
					local n1, n2 = connection[1], connection[2]
					n1, n2 = map.tree[map.tree[n1]], map.tree[map.tree[n2]]
					
					num_connections = num_connections - 1
					c = 1
					
					n1.adjacent[#n1.adjacent+1] = n2
					n1.adjacent[n2] = true
					n2.adjacent[#n2.adjacent+1] = n1
					n2.adjacent[n1] = true
					coroutine.yield()
				end
			end
			
			if num_connections ~= 0 then
				print("Not enough reconnections")
			end
		end
		
		map.nodes = nil
		coroutine.yield()
	end)
end

return Generator
