collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local Clayer = requires(IMG_PATH,"GameLuaScript/Scene/culture/culturelayer")--require "GameLuaScript/Scene/culture/culturelayer"

local info = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")--require "GameLuaScript/Scene/common/infolayer"


local M = {}

function M:create(gid)
	local scene = display.newScene("culture")

	---------------插入layer---------------------
	scene:addChild(Clayer:new(0 , 0,gid):getLayer())
	local infothis = info:new("culture", 0,{title_text = IMG_PATH.."image/scene/Culture/culture.png",closeCallback = function() switchScene("hero",{gid = gid}) end})
	scene:addChild(infothis:getLayer())
	---------------------------------------------

	return scene
end

return M
