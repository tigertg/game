collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local IncubationLayer = requires(IMG_PATH,"GameLuaScript/Scene/incubation/incubationlayer")



local M = {}

function M:create( params )
	local scene = display.newScene("incubation")
	
	local layer = IncubationLayer:new(0,70 , params )
	---------------插入layer---------------------
	scene:addChild(layer:getLayer())
	---------------------------------------------
	
	
	
	--在场景退出时停止已开始的计时器
--	function scene:onExit()
--		layer:stopSchedule()
--	end
	
	return scene
end

return M
