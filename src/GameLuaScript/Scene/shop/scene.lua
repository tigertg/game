collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local PetLayer = requires(IMG_PATH,"GameLuaScript/Scene/shop/shoplayer")--require "GameLuaScript/Scene/pet/petlayer"



local M = {}

function M:create()
	local scene = display.newScene("shop")

	---------------插入layer---------------------
	scene:addChild(PetLayer:new(0 , 0))
	---------------------------------------------

	return scene
end

return M
