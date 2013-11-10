
local oop = require "oop"
local lujgl = require "lujgl"
local gl, glc = lujgl.gl, lujgl.glconst

local Map, super = oop.Class()

function Map:__init(w,h,d)
	local this = super.__init(self)
	
	this.w = w
	this.h = h
	this.d = d
	this.rooms = {}
	
	this.layers = {}
	for i=1,d do
		this.layers[i] = {}
	end
	
	this.nodes = {}
	this.tree = {}
	
	return this
end

function Map:addRoom(room)
	self.rooms[#self.rooms+1] = room
	self.layers[room.z][#self.layers[room.z]+1] = room
end

function Map:draw(highlightlayer)
	-- Draw rooms
	for i,layer in ipairs(self.layers) do
		for _,room in ipairs(layer) do
			room:draw(i == highlightlayer and 1 or 0.2)
		end
	end
	
	gl.glClear(glc.GL_DEPTH_BUFFER_BIT)
	
	-- Draw room graph
	if self.nodes then
		gl.glBegin(glc.GL_LINES)
		for _,node in ipairs(self.nodes) do
			local cx, cy, cz = node:center()
			
			for _,other in ipairs(node.adjacent) do
				local ocx, ocy, ocz = other:center()
				
				local a = (cz == highlightlayer or ocz == highlightlayer) and 1 or 0.1
				gl.glColor4d(0.8,0.8,0.4,a)
				
				gl.glVertex3d(cx, cy, cz+0.05)
				gl.glVertex3d(ocx, ocy, ocz+0.05)
			end
		end
		gl.glEnd()
		
		gl.glBegin(glc.GL_QUADS)
		for _,node in ipairs(self.nodes) do
			local a = node.z == highlightlayer and 1 or 0.1
			if node.highlight then
				gl.glColor4d(1,0.1,0.1,a)
			else
				gl.glColor4d(1,1,0.5,a)
			end
			
			local cx, cy, cz = node:center()
			gl.glVertex3d(cx-0.1, cy, cz+0.1)
			gl.glVertex3d(cx, cy+0.1, cz+0.1)
			gl.glVertex3d(cx+0.1, cy, cz+0.1)
			gl.glVertex3d(cx, cy-0.1, cz+0.1)
		end
		gl.glEnd()
	end
	
	-- Draw minimal tree
	if self.tree then
		gl.glColor3d(0.8,0.2,0.2)
		gl.glBegin(glc.GL_LINES)
		for _,node in ipairs(self.tree) do
			local cx, cy, cz = node:center()
			
			for _,other in ipairs(node.adjacent) do
				local ocx, ocy, ocz = other:center()
				
				local a = (cz == highlightlayer or ocz == highlightlayer) and 1 or 0.1
				gl.glColor4d(0.8,0.2,0.2,a)
				
				gl.glVertex3d(cx, cy, cz+0.05)
				gl.glVertex3d(ocx, ocy, ocz+0.05)
			end
		end
		gl.glEnd()
		
		gl.glBegin(glc.GL_QUADS)
		for _,node in ipairs(self.tree) do
			local a = node.z == highlightlayer and 1 or 0.1
			if node.highlight then
				gl.glColor4d(1,0.1,0.1,a)
			else
				gl.glColor4d(1,0.3,0.3,a)
			end
			
			local cx, cy, cz = node:center()
			gl.glVertex3d(cx-0.1, cy, cz+0.1)
			gl.glVertex3d(cx, cy+0.1, cz+0.1)
			gl.glVertex3d(cx+0.1, cy, cz+0.1)
			gl.glVertex3d(cx, cy-0.1, cz+0.1)
		end
		gl.glEnd()
	end
end

return Map
