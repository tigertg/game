collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local refreshpetskillLayer = requires(IMG_PATH,"GameLuaScript/Scene/refreshpetskill/layer")



local M = {}

function M:create(args)
	local scene = display.newScene("refreshpetskill")

	---------------插入layer---------------------
	scene:addChild(refreshpetskillLayer:new(args))
	---------------------------------------------

	return scene
end

return M
