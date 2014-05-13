--[[

首页场景

]]


collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local ActivityLayer = requires(IMG_PATH,"GameLuaScript/Scene/gang/gangLayer")



local M = {}

function M:create(params)
	local scene = display.newScene( "gang" )
	---------------插入layer---------------------
	scene:addChild( ActivityLayer:new(params) )
	---------------------------------------------
	
	
	
	function scene:onEnter()
		DATA_Info:setIsMsg()
	end
	function scene:onExit()
		Clock:removeTimeFun( "task" )
		DATA_Info:addActionBtn( "gang" , nil )	----删帮会聊天 按钮标记
	end
	return scene
end

return M
