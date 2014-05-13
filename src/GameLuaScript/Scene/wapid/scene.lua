--[[

输入wap游戏id

]]


collectgarbage("setpause" , 100)
collectgarbage("setstepmul" , 5000)


-- [[ 包含各种 Layer ]]
local setting_layer = requires(IMG_PATH,"GameLuaScript/Scene/wapid/setting")



local M = {}

function M:create()
	local scene = display.newScene("wapid")
	
	---------------插入layer---------------------
	scene:addChild( setting_layer:create() )
	---------------------------------------------

	return scene
end

return M
