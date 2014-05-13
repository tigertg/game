--[[

		升阶

]]


collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")
local uplevelLayer = requires(IMG_PATH, "GameLuaScript/Scene/uplevel/uplevelLayer")

local M = {}

function M:create( params )
	local scene = display.newScene("uplevel")
	---------------插入layer---------------------
	scene:addChild( uplevelLayer:new( params ) )
	---------------------------------------------
	--信息
	local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")
	scene:addChild( InfoLayer:new("home" , 0, {tail_hide = true, title_text =  IMG_PATH .. "image/scene/uplevel/title_text.png" , closeCallback = function() popScene() end}):getLayer())
	
	return scene
end

return M
