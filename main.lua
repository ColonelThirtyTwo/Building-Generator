
math.randomseed(os.time())

local SCREEN_W, SCREEN_H = 1600, 900
local W, H, D = 30, 6, 3
local lj_glfw = require "glfw"
local bit = require "bit"
local Room = require "room"

local gl, glc, glu, glfw = lj_glfw.libraries()

lj_glfw.init()
local window = lj_glfw.Window(SCREEN_W, SCREEN_H, "Building Gen")
window:makeContextCurrent()

gl.glEnable(glc.GL_DEPTH_TEST)
gl.glDisable(glc.GL_CULL_FACE)
gl.glDisable(glc.GL_FOG)
gl.glDisable(glc.GL_LIGHTING)
gl.glEnable(glc.GL_BLEND)
gl.glBlendFunc(glc.GL_SRC_ALPHA, glc.GL_ONE_MINUS_SRC_ALPHA)

gl.glMatrixMode(glc.GL_PROJECTION)
gl.glLoadIdentity()
--gl.glOrtho(0,SCREEN_W,0,SCREEN_H,-20,20)
gl.glOrtho(-W, W, -H, H, -50, 50)

gl.glMatrixMode(glc.GL_MODELVIEW)
gl.glLoadIdentity()
glu.gluLookAt(
	20, 20, 20,
	W/2, H/2, D/2,
	0,1,0
)
--gl.glTranslated(50, 50, 0)
--gl.glScaled((SCREEN_W-100)/W, (SCREEN_W-100)/W, 1)

local updateTime = 0.05
local highlight_layer = 0
local nextUpdate = glfw.glfwGetTime() + updateTime
local map, genroutine = require("generator").generate({
	w = W, h = H, d = D,
	
	rooms = 50,
	loops = 10,
	
	genroom = function(map)
		local w,h
		if math.random() <= 0.3 then
			w, h = 1, math.random(2,4)
		else
			w, h = math.random(2,5), 1
		end
		
		local x, y, z = math.random(0,map.w-1-w), math.random(0, map.h-1-h), math.random(map.d)
		
		return Room(x,y,z,w,h)
	end
})

local function keyboard_cb(window, key, scancode, action, mods)
	if action == glc.GLFW_PRESS then
		if key == glc.GLFW_KEY_UP then
			highlight_layer = highlight_layer + 1
		elseif key == glc.GLFW_KEY_DOWN then
			highlight_layer = highlight_layer - 1
		end
		
		highlight_layer = highlight_layer % (map.d+1)
	end
end
require("jit").off(keyboard_cb)
window:setKeyCallback(keyboard_cb)

while not window:shouldClose() do
	gl.glClear(bit.bor(glc.GL_COLOR_BUFFER_BIT, glc.GL_DEPTH_BUFFER_BIT))
	
	map:draw(highlight_layer ~= 0 and highlight_layer or nil)
	
	window:swapBuffers()
	
	if coroutine.status(genroutine) == "suspended" then
		if lj_glfw.getTime() >= nextUpdate then
			local ok, tm = coroutine.resume(genroutine)
			if not ok then
				error(debug.traceback(genroutine, tostring(tm), 0), 0)
			end
			nextUpdate = nextUpdate + updateTime * (tm or 1)
		end
		lj_glfw.pollEvents()
	else
		lj_glfw.waitEvents()
	end
end

window:destroy()
lj_glfw.terminate()
