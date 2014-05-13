--[[

首页场景

]]


collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local ActivityLayer = requires(IMG_PATH,"GameLuaScript/Scene/activity/activityLayer")



local M = {}

function M:create(params)
	local scene = display.newScene( "activity" )

	---------------插入layer---------------------
	scene:addChild( ActivityLayer:new(params) )
	---------------------------------------------
	function scene:onExit()
		ActivityLayer:clearClock()
		Clock:removeTimeFun( "wineClock" )
		Clock:removeTimeFun( "payTime" )
		DATA_Activity:delWineData()
		ActivityLayer:delHandler()
	end
	return scene
end

return M
