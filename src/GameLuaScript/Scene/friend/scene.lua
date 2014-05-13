--[[

首页场景

]]


collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local FriendLayer = requires(IMG_PATH,"GameLuaScript/Scene/friend/friendLayer")



local M = {}

function M:create(params)
	local scene = display.newScene( "friend" )

	---------------插入layer---------------------
	scene:addChild( FriendLayer:new(params) )
	---------------------------------------------
	function scene:onExit()
	end
	return scene
end

return M
