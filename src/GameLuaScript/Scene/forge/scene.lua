--[[

首页场景

]]


collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local ForgeLayer = requires(IMG_PATH,"GameLuaScript/Scene/forge/forgelayer")--require "GameLuaScript/Scene/fb/fblayer"
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")--require "GameLuaScript/Scene/common/infolayer"



local M = {}

function M:create(params)
	params = params or {}
	local scene = display.newScene("forge")

	---------------插入layer---------------------
	scene:addChild(ForgeLayer:new(params or {}):getLayer())
	scene:addChild(InfoLayer:new("forge", 0, { title_hide = true }):getLayer())
--	scene:addChild(BTLuaLayer())
	---------------------------------------------

	return scene
end

return M
