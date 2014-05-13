--[[

切换场景

** Param **
	name 场景名
	temp_data 临时变量，可传递到下一个场景
	callback 回调函数

]]
function switchScene( name , temp_data , callback )
--	local cur_scene = display.getRunningScene()
--	if cur_scene and cur_scene["name"] == name then return end

	-- 去掉所有未完成的动作
	CCDirector:sharedDirector():getActionManager():removeAllActions()

	local scene_file = "GameLuaScript/Scene/" .. name .. "/scene"

	local scene = requires(IMG_PATH,scene_file)


	-- echoLog("Scene" , "Load Scene [" .. name .. "]")
	display.replaceScene( scene:create(temp_data) )

	if type(callback) == "function" then
		-- 必须延迟，不然会在替换场景之前执行
		local handle
		handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
			handle = nil

			callback()
		end , 0.1 , false)
		
	end
end

function pushScene(name,params)
	local scene_file = "GameLuaScript/Scene/" .. name .. "/scene"
	local scene = requires(IMG_PATH,scene_file)
	
	CCDirector:sharedDirector():pushScene(scene:create(params))
end

function popScene()
	CCDirector:sharedDirector():popScene()
end

