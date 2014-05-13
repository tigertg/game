--[[

新手注册

]]


collectgarbage("setpause"  , 100)
collectgarbage("setstepmul"  , 5000)


-- [[ 包含各种 Layer ]]
local newLayer = requires(IMG_PATH , "GameLuaScript/Scene/newguy/layer")--require "GameLuaScript/Scene/home/homelayer"


local M = {}

function M:create(args)
	local scene = display.newScene("newguy")

	local step = args.step or 6

	---------------插入layer---------------------
	scene:addChild( newLayer:new( args.open_id , step ) )
	---------------------------------------------

	return scene
end

return M
