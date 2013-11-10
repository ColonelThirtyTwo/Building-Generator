
local oop = require "oop"
local lujgl = require "lujgl"
local gl, glc = lujgl.gl, lujgl.glconst

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

function Room:center()
	return self.x + self.w/2, self.y + self.h/2
end

function Room:intersects(other)
	if self.z ~= other.z then return false end
	
	local selfcx, selfcy = self.x + self.w/2, self.y + self.h/2
	local othercx, othercy = other.x + other.w/2, other.y + other.h/2
	
	local dx, dy = math.abs(selfcx - othercx), math.abs(selfcy - othercy)
	return (dx < (self.w + other.w)/2) and (dy < (self.h + other.h)/2)
end

function Room:draw()
	gl.glColor3d(0,0,1)
	gl.glBegin(glc.GL_QUADS)
		gl.glVertex2d(self.x+0.1,self.y+0.1)
		gl.glVertex2d(self.x+0.1,self.y+self.h-0.1)
		gl.glVertex2d(self.x+self.w-0.1,self.y+self.h-0.1)
		gl.glVertex2d(self.x+self.w-0.1,self.y+0.1)
	gl.glEnd()
end

return Room
