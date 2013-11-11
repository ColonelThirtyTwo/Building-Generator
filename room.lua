
local oop = require "oop"
local gl, glc = require("glfw").libraries()

local Room, super = oop.Class()

local function hsv2rgb(h, s, v)
	if s == 0 then
		return v, v, v
	end
	
	h = (h % 360) / 60
	local i = math.floor(h)
	local f = h - i
	
	local p = v*(1-s)
	local q = v*(1-s*f)
	local t = v*(1-s*(1-f))
	
	if i == 0 then
		return v, t, p
	elseif i == 1 then
		return q, v, p
	elseif i == 2 then
		return p, v, t
	elseif i == 3 then
		return p, q, v
	elseif i == 4 then
		return t, p, v
	elseif i == 5 then
		return v, p, q
	else
		assert(false)
	end
end

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

function Room:draw(a)
	local r,g,b = hsv2rgb(self.z * 60 + 180, 1, 0.5)
	gl.glColor4d(r,g,b,a or 1)
	gl.glBegin(glc.GL_QUADS)
		gl.glVertex3d(self.x+0.1,self.y+0.1, self.z)
		gl.glVertex3d(self.x+0.1,self.y+self.h-0.1, self.z)
		gl.glVertex3d(self.x+self.w-0.1,self.y+self.h-0.1, self.z)
		gl.glVertex3d(self.x+self.w-0.1,self.y+0.1, self.z)
	gl.glEnd()
end

function Room:__tostring()
	return string.format("Room:(%d,%d,%d)x(%d,%d)", self.x, self.y, self.z, self.w, self.h)
end

return Room
