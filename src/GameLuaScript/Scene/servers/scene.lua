--[[

选区

]]


collectgarbage("setpause" , 100)
collectgarbage("setstepmul" , 5000)


-- [[ 包含各种 Layer ]]
local servers_layer = requires(IMG_PATH,"GameLuaScript/Scene/servers/servers")
local version = requires(IMG_PATH,"GameLuaScript/Config/version")



local M = {}

function M:create( params )
	params = params or {}

	local scene = display.newScene("servers")
	
	---------------插入layer---------------------
	scene:addChild( servers_layer:create( params ) )
	---------------------------------------------
	
	function scene:onEnter()
		if device.platform == "ios" and tonumber( version:get_VERSION() ) <= 1309119 then
			local url
			if CHANNEL_ID == "tmsjios"  then
				--"唐门下载地址"
			    url = "http://www.szkuniu.com/tmsj/m/index.html"
			elseif CHANNEL_ID == "dhshIosIpay"  then
				-- "大话水浒下载地址"
			    url = "http://www.szkuniu.com/dhsh/m/index.html" 
			end
			
			KNMsg.getInstance():boxShow( "温馨提示：如果您在游戏中有部分功能无法正常使用，\n请点击“确定”下载新的安装包重新安装。" ,{ 
																			confirmText = COMMONPATH .. "confirm.png" , 
																			confirmFun = function()
																				UpdateDataOC:getInstance():openUrl(url)										
																			end , 
																			cancelFun = function() end 
																			} )
		end
	end
	return scene
end

return M
