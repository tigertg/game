--[[

首页场景

]]


collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local FBLayer = requires(IMG_PATH,"GameLuaScript/Scene/fb/fblayer")--require "GameLuaScript/Scene/fb/fblayer"



local M = {}

function M:create(params)
	local scene = display.newScene("fb")

	---------------插入layer---------------------
	scene:addChild(FBLayer:new(params):getLayer())
	---------------------------------------------

	return scene
end

return M
