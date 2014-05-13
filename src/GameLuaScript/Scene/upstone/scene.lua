collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 升级石头 ]]
local stonePlayer = requires(IMG_PATH,"GameLuaScript/Scene/upstone/upstoneLayer")--require "GameLuaScript/Scene/upstone/upstoneLayer"

local info = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")--require "GameLuaScript/Scene/common/infolayer"


local M = {}

function M:create()
	local scene = display.newScene("upstone")

	---------------插入layer---------------------
	scene:addChild(stonePlayer:new(0 , 0):getLayer())
	local infothis = info:new(0 , 0)
	infothis:showInfo(1)
	scene:addChild(infothis:getLayer())
	---------------------------------------------

	return scene
end

return M
