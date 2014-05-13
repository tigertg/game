--[[

首页场景

]]


collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local PVPLayer = requires(IMG_PATH,"GameLuaScript/Scene/pvp/pvplayer")--require "GameLuaScript/Scene/fb/fblayer"



local M = {}

function M:create(params)
	local scene = display.newScene("pvp")

	---------------插入layer---------------------
	scene:addChild(PVPLayer:new(params):getLayer())
	---------------------------------------------

	return scene
end

return M
