collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]

local layer = requires(IMG_PATH,"GameLuaScript/Scene/ranklist/ranklayer")

local M = {}

function M:create(parm)
	local scene = display.newScene("ranklist")
	---------------插入layer---------------------
	
		scene:addChild(layer:new(parm):getLayer())
	---------------------------------------------

	return scene
end

return M
