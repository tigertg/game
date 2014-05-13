collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local Pulselayer = requires(IMG_PATH,"GameLuaScript/Scene/pulse/Pulselayer")
local infoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")


local M = {}

function M:create(gid)
	local scene = display.newScene("pulse")

	---------------插入layer---------------------
	scene:addChild(Pulselayer:new(gid):getLayer())
	
	local info_layer = infoLayer:new("pulse", 0,{title_text = IMG_PATH.."image/scene/Pulse/title.png",closeCallback = function() switchScene("hero",{gid = gid}) end})
	scene:addChild(info_layer:getLayer())
	---------------------------------------------

	return scene
end

return M
