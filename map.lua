
local oop = require "oop"

local Map, super = oop.Class()

function Map:__init(w,h)
	local this = super.__init(self)
	
	this.w = w
	this.h = h
	this.rooms = {}
	
	return this
end

return Map
