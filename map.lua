
local oop = require "oop"
local lujgl = require "lujgl"
local gl, glc = lujgl.gl, lujgl.glconst

local Map, super = oop.Class()

function Map:__init(w,h)
	local this = super.__init(self)
	
	this.w = w
	this.h = h
	this.rooms = {}
	this.nodes = {}
	
	return this
end

function Map:draw()
	gl.glColor3d(0.1, 0.1, 0.1)
	gl.glBegin(glc.GL_QUADS)
		gl.glVertex3d(-20,-20, -0.1)
		gl.glVertex3d(-20,0.3, -0.1)
		gl.glVertex3d(self.w+20,0.3, -0.1)
		gl.glVertex3d(self.w+20,-20, -0.1)
	gl.glEnd()
	
	for _,room in ipairs(self.rooms) do
		room:draw()
	end
	
	for _,node in ipairs(self.nodes) do
		local cx, cy = node.x + 0.5, node.y + 0.5
		
		gl.glColor3d(0.8,0.8,0.4)
		gl.glBegin(glc.GL_LINES)
		for _,other in ipairs(node.adjacent) do
			local ocx, ocy = other.x + 0.5, other.y + 0.5
			gl.glVertex3d(cx, cy, 0.5)
			gl.glVertex3d(ocx, ocy, 0.5)
		end
		gl.glEnd()
		
		gl.glColor3d(1,1,0.5)
		gl.glBegin(glc.GL_QUADS)
			gl.glVertex3d(cx-0.1, cy, 1)
			gl.glVertex3d(cx, cy+0.1, 1)
			gl.glVertex3d(cx+0.1, cy, 1)
			gl.glVertex3d(cx, cy-0.1, 1)
		gl.glEnd()
	end
end

return Map
