collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local LUPlayer = requires(IMG_PATH,"GameLuaScript/Scene/mosaic/Mosaiclayer")--require "GameLuaScript/Scene/mosaic/Mosaiclayer"

local info = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")--require "GameLuaScript/Scene/common/infolayer"


local M = {}

function M:create(parm)
	local scene = display.newScene("mosaic")

	---------------插入layer---------------------
	scene:addChild(LUPlayer:new(0 , 0 , parm):getLayer())
	local infothis = info:new("mosaic", 0,{title_text = IMG_PATH.."image/scene/Pulse/title.png",closeCallback = function() switchScene("pulse",parm.gid) end})
	--infothis:showInfo(false)
	scene:addChild(infothis:getLayer())
	---------------------------------------------

	return scene
end

return M
