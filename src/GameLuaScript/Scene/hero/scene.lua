collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local HeroLayer = requires(IMG_PATH,"GameLuaScript/Scene/hero/herolayer")



local M = {}

function M:create(args)
	local scene = display.newScene("hero")

	---------------插入layer---------------------
	scene:addChild(HeroLayer:new(args))
	---------------------------------------------
	
	function scene:onEnter()
		HeroLayer:checkAdvancedEquip()
	end
	return scene
end

return M
