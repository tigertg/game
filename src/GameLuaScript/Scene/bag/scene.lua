--[[

首页场景

]]


collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")--require "GameLuaScript/Scene/common/infolayer"
local BagLayer = requires(IMG_PATH, "GameLuaScript/Scene/bag/baglayer")--require "GameLuaScript/Scene/bag/baglayer"



local M = {}

function M:create(data)
	local scene = display.newScene("bag")
	---------------插入layer---------------------
	scene:addChild(BagLayer:new(data))
	---------------------------------------------
	return scene
end

return M
