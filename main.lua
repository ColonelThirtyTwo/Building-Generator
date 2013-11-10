
math.randomseed(os.time())

local SCREEN_W, SCREEN_H = 1600, 900
local W, H, D = 30, 6, 3
local lujgl = require "lujgl"
local bit = require "bit"

local gl, glu, glc, glfw = lujgl.gl, lujgl.glu, lujgl.glconst, lujgl.glfw

assert(glfw.glfwInit() ~= 0)
local window = glfw.glfwCreateWindow(1600, 900, "Test", nil, nil)
assert(window ~= nil)

glfw.glfwMakeContextCurrent(window)

gl.glDisable(glc.GL_DEPTH_TEST)
gl.glDisable(glc.GL_CULL_FACE)
gl.glDisable(glc.GL_FOG)
gl.glDisable(glc.GL_LIGHTING)

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
local nextUpdate = glfw.glfwGetTime() + updateTime
local map, genroutine = require("generator").generate(W,H)

while glfw.glfwWindowShouldClose(window) == 0 do
	gl.glClear(bit.bor(glc.GL_COLOR_BUFFER_BIT, glc.GL_DEPTH_BUFFER_BIT))
	
	map:draw()
	
	glfw.glfwSwapBuffers(window)
	
	if coroutine.status(genroutine) == "suspended" then
		if glfw.glfwGetTime() >= nextUpdate then
			local ok, tm = coroutine.resume(genroutine)
			if not ok then
				error(debug.traceback(tostring(tm), 0, genroutine), 0)
			end
			nextUpdate = nextUpdate + updateTime * (tm or 1)
		end
		glfw.glfwPollEvents()
	else
		glfw.glfwWaitEvents()
	end
end

glfw.glfwTerminate()
