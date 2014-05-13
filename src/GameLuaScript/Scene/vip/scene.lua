collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local VipLayer = requires(IMG_PATH,"GameLuaScript/Scene/vip/viplayer")



local M = {}

function M:create( params )
	local scene = display.newScene("vip")

	---------------插入layer---------------------
	local viplayer = VipLayer:new( params )
	scene:addChild( viplayer )
	---------------------------------------------
	function scene:onExit()
	end

	return scene
end

return M
