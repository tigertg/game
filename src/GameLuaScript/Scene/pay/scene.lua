collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local payLayer = requires(IMG_PATH,"GameLuaScript/Scene/pay/paylayer")



local M = {}

function M:create(args)
	local scene = display.newScene("pay")

	---------------插入layer---------------------
	scene:addChild(payLayer:new(args))
	---------------------------------------------
	return scene
end

return M
