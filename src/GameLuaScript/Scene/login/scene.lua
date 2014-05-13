--[[

登录场景

]]


collectgarbage("setpause" , 100)
collectgarbage("setstepmul" , 5000)


-- [[ 包含各种 Layer ]]
local loginbox_layer = requires(IMG_PATH,"GameLuaScript/Scene/login/loginbox")



local M = {}

function M:create( params )
	params = params or {}
	--[[数据初始化]]
	requires(IMG_PATH , "GameLuaScript/Network/commonActions"):init()

	local scene = display.newScene("login")
	
	if KNFileManager.readfile("savefile.txt" , "sound" , "=") == "0" then
		audio.playMusic( IMG_PATH .. "sound/login.mp3" , true )
	else
		audio.stopMusic( false )
		audio.disable()
	end
	
	---------------插入layer---------------------
	scene:addChild( loginbox_layer:create( params ) )
	---------------------------------------------

	return scene
end

return M
