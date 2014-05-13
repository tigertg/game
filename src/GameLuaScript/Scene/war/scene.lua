collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local WarLayer = requires(IMG_PATH,"GameLuaScript/Scene/war/warlayer")

GANG_WAR = nil

local M = {}

function M:create(args)
	local scene = display.newScene("war")

	---------------插入layer---------------------
	GANG_WAR = WarLayer:new(args)
	scene:addChild(GANG_WAR:getLayer())
	---------------------------------------------

	return scene
end


return M
