collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local showLayer = requires(IMG_PATH , "GameLuaScript/Scene/chat/showLayer")



local M = {}

function M:create(args)
	local scene = display.newScene("chat")

	---------------插入layer---------------------
	local chat_layer
	chat_layer = showLayer:new()
	scene:addChild( chat_layer:getLayer() )
	---------------------------------------------

	-- 刷新聊天界面数据
	function scene:refreshChat(message_type)
		chat_layer:refreshChatContent(message_type)
	end

	return scene
end

return M
