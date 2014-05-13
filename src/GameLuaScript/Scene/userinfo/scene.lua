collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local UserInfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/userinfo/userinfolayer")--require "GameLuaScript/Scene/pet/petlayer"



local M = {}

function M:create(rank)
	local scene = display.newScene("userinfo")

	---------------插入layer---------------------
	local info = UserInfoLayer:new(rank)
	scene:addChild(info:getLayer())
	---------------------------------------------
	function scene:onExit()
		info:stopSchedule()
	end

	return scene
end

return M
