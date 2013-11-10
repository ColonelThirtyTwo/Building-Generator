
local oop = require "oop"

local Room, super = oop.Class()

function Room:__init(x,y,z,w,h)
	local this = super.__init(self)
	this.x = x
	this.y = y
	this.z = z
	this.w = w
	this.h = h
	return this
end

function Room:intersects(other)
	if self.z ~= other.z then return false end
	
	local selfcx, selfcy = self.x + self.w/2, self.y + self.h/2
	local othercx, othercy = other.x + other.w/2, other.y + other.h/2
	
	local dx, dy = math.abs(selfcx - othercx), math.abs(selfcy - othercy)
	return (dx < (self.w + other.w)/2) and (dy < (self.h + other.h)/2)
end

function Room:draw(gl, glc)
	gl.glColor3d(0,0,1)
	gl.glBegin(glc.GL_QUADS)
		gl.glVertex2d(self.x+0.1,self.y+0.1)
		gl.glVertex2d(self.x+0.1,self.y+self.h-0.1)
		gl.glVertex2d(self.x+self.w-0.1,self.y+self.h-0.1)
		gl.glVertex2d(self.x+self.w-0.1,self.y+0.1)
	gl.glEnd()
	
	if self.adjacent then
		local cx, cy = self.x + self.w/2, self.y + self.h/2
		
		gl.glColor3d(0.8,0.8,0.4)
		gl.glBegin(glc.GL_LINES)
		for _,other in ipairs(self.adjacent) do
			local ocx, ocy = other.x + other.w/2, other.y + other.h/2
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

return Room
