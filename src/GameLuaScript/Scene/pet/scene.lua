collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local PetLayer = requires(IMG_PATH,"GameLuaScript/Scene/pet/petlayer")--require "GameLuaScript/Scene/pet/petlayer"



local M = {}

function M:create(args)
	local scene = display.newScene("pet")

	---------------插入layer---------------------
	scene:addChild(PetLayer:new(args))
	---------------------------------------------

	return scene
end

return M
