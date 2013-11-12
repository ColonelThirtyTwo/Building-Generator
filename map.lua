
local oop = require "oop"
local gl, glc = require("glfw").libraries()

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
	-- Draw each layer individually
	for i=1,#self.layers do
		local layer = self.layers[i]
		--gl.glClear(glc.GL_DEPTH_BUFFER_BIT)
		
		for _,room in ipairs(layer) do
			room:draw((not highlightlayer or i == highlightlayer) and 0.8 or 0.2)
		end
		
		if self.addtionalDrawFuncs then
			for _,f in ipairs(self.addtionalDrawFuncs) do
				f(i, highlightlayer)
			end
		end
	end
end

return Map
