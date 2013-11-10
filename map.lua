
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
	this.nodes = {}
	this.tree = {}
	
	return this
end

function Map:draw()
	-- Draw floor
	--[[gl.glColor3d(0.1, 0.1, 0.1)
	gl.glBegin(glc.GL_QUADS)
		gl.glVertex3d(-20,-20, -0.1)
		gl.glVertex3d(-20,0.3, -0.1)
		gl.glVertex3d(self.w+20,0.3, -0.1)
		gl.glVertex3d(self.w+20,-20, -0.1)
	gl.glEnd()]]
	
	-- Draw rooms
	for _,room in ipairs(self.rooms) do
		room:draw()
	end
	
	-- Draw room graph
	if self.nodes then
		gl.glBegin(glc.GL_LINES)
		gl.glColor3d(0.8,0.8,0.4)
		for _,node in ipairs(self.nodes) do
			local cx, cy = node:center()
			
			for _,other in ipairs(node.adjacent) do
				local ocx, ocy = other:center()
				gl.glVertex3d(cx, cy, 0)
				gl.glVertex3d(ocx, ocy, 0)
			end
		end
		gl.glEnd()
		
		gl.glBegin(glc.GL_QUADS)
		for _,node in ipairs(self.nodes) do
			if node.highlight then
				gl.glColor3d(1,0.1,0.1)
			else
				gl.glColor3d(1,1,0.5)
			end
			
			local cx, cy = node:center()
			gl.glVertex3d(cx-0.1, cy, 0)
			gl.glVertex3d(cx, cy+0.1, 0)
			gl.glVertex3d(cx+0.1, cy, 0)
			gl.glVertex3d(cx, cy-0.1, 0)
		end
		gl.glEnd()
	end
	
	-- Draw minimal tree
	if self.tree then
		gl.glColor3d(0.8,0.2,0.2)
		gl.glBegin(glc.GL_LINES)
		for _,node in ipairs(self.tree) do
			local cx, cy = node:center()
			
			for _,other in ipairs(node.adjacent) do
				local ocx, ocy = other:center()
				gl.glVertex3d(cx, cy, 0)
				gl.glVertex3d(ocx, ocy, 0)
			end
		end
		gl.glEnd()
		
		gl.glBegin(glc.GL_QUADS)
		for _,node in ipairs(self.tree) do
			if node.highlight then
				gl.glColor3d(1,0.1,0.1)
			else
				gl.glColor3d(1,0.3,0.3)
			end
			
			local cx, cy = node:center()
			gl.glVertex3d(cx-0.1, cy, 0)
			gl.glVertex3d(cx, cy+0.1, 0)
			gl.glVertex3d(cx+0.1, cy, 0)
			gl.glVertex3d(cx, cy-0.1, 0)
		end
		gl.glEnd()
	end
end

return Map
