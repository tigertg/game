--[[

首页场景

]]


collectgarbage("setpause"  , 100)
collectgarbage("setstepmul"  , 5000)


-- [[ 包含各种 Layer ]]
local homeLayer = requires(IMG_PATH,"GameLuaScript/Scene/home/homelayer")
local infoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")
local M = {}
function M:create()
--	local noticeData = DATA_Notice:get()
	
	local scene = display.newScene("home")
	
	---------------插入layer---------------------
	scene:addChild( homeLayer:new() )
	scene:addChild( infoLayer:new("home" , 3):getLayer() )
	---------------------------------------------

	if KNFileManager.readfile("savefile.txt" , "sound" , "=") == "0" then
	else
		audio.stopMusic( false )
		audio.disable()
	end
	
	if KNFileManager.readfile("savefile.txt" , "audio" , "=") == "0" then
		audio.setIsEffect( true )
	else
		audio.setIsEffect( false )
	end
	
	if audio.isMusicPlaying() == false then
		audio.preloadMusic(IMG_PATH .. "sound/background.mp3")
		SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(1)
		audio.playMusic( IMG_PATH .. "sound/background.mp3" , true )
	end
	
	
	
	local handle
	local function createNotice()
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
		handle = nil
		if DATA_Notice:getIsFirst() then
			local noticeData = DATA_Notice:get()
			if noticeData.broadcast then
				local noticeLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/notice")
				local curScene = display.getRunningScene()
				curScene:addChild( noticeLayer:new():getLayer() )
			end
		end
	end
	handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc( createNotice , 0.01 , false)
	


	-- 心跳包
	
	if not Clock:getKeyIsExist("heartbeat") then
		CCLuaLog("create heart beat")

		local times = 0
		local heartbeat_function = function()
			times = times + 1
			
			if times > 120 then
				local cur_scene = display.getRunningScene()
				if cur_scene.name == "battle" then return end

				SOCKET:getInstance("battle"):call("heartbeat" , "go" , "heartbeat" , {} , {
					no_mask = true,
					error_callback = function(data)
						print("heartbeat failed")
					end
				})

				times = 0
			end
		end
		Clock:addTimeFun( "heartbeat" , heartbeat_function )
	end

	function scene:onEnter()
		DATA_Info:setIsMsg()
	end
	function scene:onExit()
		DATA_Info:setIsOpen()
		DATA_Info:addActionBtn( "home" , nil )	--删主界面聊天动画标记
	end
	return scene
end

return M
