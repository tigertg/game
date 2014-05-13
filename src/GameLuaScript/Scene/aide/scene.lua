--[[

首页场景

]]


collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local AideLayer = requires(IMG_PATH,"GameLuaScript/Scene/aide/aideLayer")



local M = {}

function M:create(params)
	local scene = display.newScene( "aide" )
	
	---------------插入layer---------------------
	scene:addChild( AideLayer:new( params ) )
	---------------------------------------------
	function scene:onExit()
	end
	return scene
end

return M
