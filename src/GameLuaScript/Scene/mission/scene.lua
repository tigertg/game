--[[

首页场景

]]


collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local MissionLayer = requires(IMG_PATH,"GameLuaScript/Scene/mission/missionlayer")--require "GameLuaScript/Scene/mission/missionlayer"
local InfoLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")--require "GameLuaScript/Scene/common/infolayer"


local M = {}

function M:create(data)
	local scene = display.newScene("mission")
	
	if not data then
		---------------插入layer---------------------
		scene:addChild(MissionLayer:new():getLayer())
		---------------------------------------------
	else
		local function addScene()
			scene:addChild(MissionLayer:new(data):getLayer())
			
			if data.passFun then
				local handle
				handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
					handle = nil
		
					data.passFun()
				end , 0.1 , false)
			end
		end
		DATA_Mission:setByKey("current","map_id",data["level"])
		if DATA_Mission:haveData(data["level"]) then
			addScene()
		else
			HTTP:call("mission","get",{map_id = data["level"]},{success_callback = addScene, error_callback = function()
				switchScene("home", nil, function()
					KNMsg.getInstance():flashShow("网络请求失败，请检查网络或重试！")
				end)
			end })
			
		end
		
	end

	return scene
end

return M
