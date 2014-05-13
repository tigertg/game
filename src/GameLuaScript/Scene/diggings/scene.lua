
collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local Layer = requires(IMG_PATH, "GameLuaScript/Scene/diggings/diggingslayer")



local M = {}

function M:create(data)
	local scene = display.newScene("diggings")
	

	local layer = Layer:new(data)
	---------------插入layer---------------------
	scene:addChild(layer:getLayer())
	---------------------------------------------

	return scene
end

return M
