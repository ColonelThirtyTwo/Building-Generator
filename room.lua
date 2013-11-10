
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

function Room:draw(gl, glc)
	gl.glColor3d(0,0,1)
	gl.glBegin(glc.GL_QUADS)
		gl.glVertex2d(self.x+0.1,self.y+0.1)
		gl.glVertex2d(self.x+0.1,self.y+self.h-0.1)
		gl.glVertex2d(self.x+self.w-0.1,self.y+self.h-0.1)
		gl.glVertex2d(self.x+self.w-0.1,self.y+0.1)
	gl.glEnd()
end

return Room
