collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local HeroLayer = requires(IMG_PATH,"GameLuaScript/Scene/otherHero/otherherolayer")--require "GameLuaScript/Scene/hero/herolayer"



local M = {}

function M:create(args)
	local scene = display.newScene("otherhero")

	---------------插入layer---------------------
	scene:addChild(HeroLayer:new(args))
	---------------------------------------------
	return scene
end

return M
