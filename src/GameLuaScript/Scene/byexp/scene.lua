--[[

		传功

]]


collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")
local byExpLayer = requires(IMG_PATH, "GameLuaScript/Scene/byexp/byexplayer")

local M = {}

function M:create( params )
	local scene = display.newScene("byexp")
	---------------插入layer---------------------
	scene:addChild( byExpLayer:new( params ) )
	---------------------------------------------
	
	return scene
end

return M
