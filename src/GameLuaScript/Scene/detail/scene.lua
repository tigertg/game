--[[

详情场景

]]


collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local detailLayer = requires(IMG_PATH , "GameLuaScript/Scene/detail/detailLayer")



local M = {}

function M:create(params)
	local scene = display.newScene("detail")

	---------------插入layer---------------------
	scene:addChild( detailLayer:new(params.detail , params):getLayer() )
	---------------------------------------------

	return scene
end

return M
