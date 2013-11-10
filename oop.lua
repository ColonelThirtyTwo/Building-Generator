--[[

Basic OOP library for Lua

Supports classes with single inheritance. Example usage:

	local oop = require "oop"
	
	-- Create the class and gets a superclass variable.
	-- oop.Class() can take a superclass as an argument.
	-- If none is specified, the default superclass is used, which contains the
	-- topmost __init method
	local MyClass, super = oop.Class()
	
	-- Our initializer.
	-- This is similar to a constructor, but it also takes care of allocating and
	-- returning the new instance (more similar to __new__ in Python).
	-- This is a class method. `self` here refers to the class being initialized
	-- (which may be a subclass)
	function MyClass:__init(a, b, c)
		
		-- Run the superintializer. The topmost initializer returns setmetatable({}, self)
		local this = super.__init(self)
		
		-- Do whatever initialization code you want, with the `this` variable as
		-- the new instance
		this.a = a
		this.b = b
		this.c = c
		
		-- At the end, return the instance we made.
		-- If this is a superclass initializer, we drop down to the next subclass's initializer.
		-- Otherwise, this will return the new instance to the client code
		return this
	end
	
	-- Specify whatever methods you want.
	function MyClass:myMethod()
	end
	
	-- At the end, return your class. This makes require() register and return your class
	return MyClass

]]


local OOP = {}

-- Class metatables cache
local classMetatables = {}

local function class_new(self, ...)
	return self:__init(...)
end

local DefaultBase = {}
function DefaultBase:__init(t) return setmetatable(t or {},self) end

--- Creates a new class.
function OOP.Class(base)
	-- Default to the default base class
	base = base or DefaultBase
	
	-- Retrieve the class' metatable from the cache, or make a new one
	local mt
	if classMetatables[base] then
		mt = classMetatables[base]
	else
		mt = {}
		mt.__index = base
		mt.__call = class_new
		classMetatables[base] = mt
	end
	
	-- Make the actual class
	local cls = setmetatable({}, mt)
	
	if not base.__index or base.__index == base then
		-- __index unmodified, set __index to class
		cls.__index = cls
	else
		-- __index modified, inherit it
		cls.__index = base.__index
	end
	
	return cls, base
end

--- Returns the class of object v
function OOP.ClassOf(v)
	return getmetatable(v)
end

--- Returns the superclass of class c.
-- Note: This returns nil if the object's super class is the default super class
-- (i.e. nothing was passed to Class())
function OOP.SuperClass(c)
	local super = getmetatable(c).__index
	if super == DefaultBase then
		return nil
	else
		return super
	end
end

return OOP
