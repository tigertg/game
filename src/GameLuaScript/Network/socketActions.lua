--[[

所有 socket 通信发送前以及回调

]]


local M = {}

--[[登录]]
function M.log_in( type , data , callback )
	if type == 1 then
	elseif type == 2 then
		--if callback ~= nil then
		--	callback(data)
		--end
	end

	return true , data
end

--[[被踢下线-接收服务器数据]]
function M.heartbeat_go( type , data , callback )
	if type == 1 then
	elseif type == 2 then
		dump(data)
	end

	return true , data
end

--[[被踢下线-接收服务器数据]]
function M.kick_off( type , data , callback )
	if type == 1 then
	elseif type == 2 then
		print("kick_off  !!!!!!!!")
		KNMsg.getInstance():boxShow(data.msg , {
			confirmFun = function()
				SOCKET:delInstance( "battle" )
				switchScene("login")
			end
		})
	end

	return true , data
end

--[[聊天-接收服务器数据]]
function M.chat_get( type , data , callback )
	if type == 1 then
	elseif type == 2 then

		local scene = display.getRunningScene()

			--[[
			DATA_Chat:addData(data)

			local scene = display.getRunningScene()
			if scene.name ~= "battle" then		-- 战斗没法刷新
				GLOBAL_INFOLAYER:update()
			end

			if scene.name == "chat" then
				scene:refreshChat()
			end
		]]
		
		DATA_Chat:addData(data["add"])
		if scene.name ~= "battle" and data["add"] and GLOBAL_INFOLAYER then		-- 战斗没法刷新
		 	GLOBAL_INFOLAYER:update()
		end
		
		
		if scene.name == "chat" then
			if data["type"] == "talk" then
				DATA_Info:insert("_G_message_talk" , data["add"] )
			end
			scene:refreshChat(data["type"])
		end
		
		if data["type"] == "talk" then
			DATA_Info:msgSource( "world" )
			DATA_Info:setIsMsg( true )
		end
		
		if data["type"] == "talk" and not DATA_Info:getIsOpen() and TALK:getType() == "world" then
			DATA_Info:insert("_G_message_talk" , data["add"] )
			TALK:addItem( data["add"] , "world" )
		end
		
	end

	return true , data
end

--[[帮派聊天-接收服务器数据]]
function M.alliancemsg_get( type , data , callback )
	if type == 1 then
	elseif type == 2 then
		DATA_Info:insert( "gang" , data.info )
		
		DATA_Info:msgSource( "gang" )
		DATA_Info:setIsMsg( true )
		
		if not DATA_Info:getIsOpen() and TALK:getType() == "gang" then
			TALK:addItem( TALK:gangDataCell( data.info ) , "gang" )
		end
		
	end

	return true , data
end
--[[私聊-接收服务器数据]]
function M.message_siliao( type , data , callback )
	if type == 1 then
	elseif type == 2 then
		DATA_Info:insert( "friend" , data.result )
		
		DATA_Info:msgSource( "friend" )
		DATA_Info:setIsMsg( true )
		
		if not DATA_Info:getIsOpen() and TALK:getType() == "friend" then
			TALK:addItem( nil , "friend" )
		end
		
	end

	return true , data
end


--[[服务器推送消息数字]]
function M.chat_num( type , data , callback )
	if type == 1 then
	elseif type == 2 then

		local scene = display.getRunningScene()

		DATA_Chat:setNum(data["num"])

		if scene.name ~= "battle" and data["num"] and GLOBAL_INFOLAYER then		-- 战斗没法刷新
			GLOBAL_INFOLAYER:update("info")
		end
	end

	return true , data
end

function M.refresh_vars( type , data , callback )
	if type == 1 then
	elseif type == 2 then
		if data["_G_"] then
			local commonActions = requires(IMG_PATH , "GameLuaScript/Network/commonActions")
			commonActions.saveCommonData( {result = data["_G_"]} )

			local scene = display.getRunningScene()
			if scene.name ~= "battle" and data["_G_"]["_G_account"] and GLOBAL_INFOLAYER then		-- 战斗没法刷新
				GLOBAL_INFOLAYER:update()
			end
		end

		if data['message'] then
			KNMsg.getInstance():flashShow(data["message"])
		end
	end

	return true , data
end

--[[关卡-战斗开始]]
function M.mission_execute( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:setMod("mission")
		DATA_Battle:setAct("execute")
		DATA_Battle:set( data["result"] )

--		switchScene("battle")
		switchScene("battle" , { intoAnimation = true , showInfo = "入场动画介绍入场动画\n介绍入场动画介绍入场动画\n介绍入场动画介绍入场动画介绍入\n场动画介绍"})
	end

	return true , data
end


--[[关卡-战斗过程]]
function M.mission_execute_process( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:set( data["result"] )
		-- 恢复战斗进程
		
		local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")--require("GameLuaScript/Scene/battle/logicLayer")
		logic:resume("socket")
	end

	return true , data
end

--[[关卡-战斗完成]]
function M.mission_execute_finish( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		local result = data["result"]
		--存储数据
		DATA_Mission:setByKey(result["current"]["map_id"],"missions",result["missions"])
		DATA_Mission:setByKey("current",result["jump"])
		DATA_Mission:setByKey("max",result["max"])

		--结束画面用数据
		DATA_Result:set( result )
		
	end
	return true , data
end


--[[ 副本-战斗开始]]
function M.inshero_execute( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:setMod("inshero")
		DATA_Battle:setAct("execute")
		DATA_Battle:set( data["result"] )

		switchScene("battle")
	end

	return true , data
end

--[[副本--战斗过程]]
function M.inshero_execute_process( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:set( data["result"] )


		-- 恢复战斗进程
		local logic =requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")-- require("GameLuaScript/Scene/battle/logicLayer")
		logic:resume("socket")
	end

	return true , data
end

--[[副本-战斗完成]]
function M.inshero_execute_finish( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		local result = data["result"]
		--结束画面用数据
		DATA_Result:set( result )
		DATA_Instance:set("hero",data["result"]["get"])
	end

	return true , data
end

--------------------------------
function M.inspet_execute( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:setMod("inspet")
		DATA_Battle:setAct("execute")
		DATA_Battle:set( data["result"] )

		switchScene("battle")
	end

	return true , data
end

--[[副本--战斗过程]]
function M.inspet_execute_process( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:set( data["result"] )


		-- 恢复战斗进程
		local logic =requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")-- require("GameLuaScript/Scene/battle/logicLayer")
		logic:resume("socket")
	end

	return true , data
end

--[[副本-战斗完成]]
function M.inspet_execute_finish( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		local result = data["result"]
		--结束画面用数据
		DATA_Result:set( result )
		DATA_Instance:set("pet",data["result"]["get"])
	end

	return true , data
end

--[[ 副本-战斗开始]]
function M.insequip_execute( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:setMod("insequip")
		DATA_Battle:setAct("execute")
		DATA_Battle:set( data["result"] )

		switchScene("battle")
	end

	return true , data
end

--[[副本--战斗过程]]
function M.insequip_execute_process( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:set( data["result"] )


		-- 恢复战斗进程
		local logic =requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")-- require("GameLuaScript/Scene/battle/logicLayer")
		logic:resume("socket")
	end

	return true , data
end

--[[副本-战斗完成]]
function M.insequip_execute_finish( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		local result = data["result"]
		--结束画面用数据
		DATA_Result:set( result )
		DATA_Instance:set("equip",result["get"]["current_map"],result["get"]["instance"])
		DATA_Instance:set("equip","max",result["get"]["max"])
		DATA_Instance:set("equip","current",result["get"]["current"])
		DATA_Instance:set("equip","point",result["get"]["point"])
	end

	return true , data
end


------------------

--[[ 副本-战斗开始]]
function M.insskill_execute( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:setMod("insskill")
		DATA_Battle:setAct("execute")
		DATA_Battle:set( data["result"] )

		switchScene("battle")
	end

	return true , data
end

--[[副本--战斗过程]]
function M.insskill_execute_process( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:set( data["result"] )


		-- 恢复战斗进程
		local logic =requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")-- require("GameLuaScript/Scene/battle/logicLayer")
		logic:resume("socket")
	end

	return true , data
end

--[[副本-战斗完成]]
function M.insskill_execute_finish( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		local result = data["result"]
		--更新技能副本数据
		DATA_Instance:set("skill",data["result"]["get"])
		--结束画面用数据
		DATA_Result:set( result )
	end

	return true , data
end

--[[ 竞技-战斗开始]]
function M.athletics_execute( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:setMod("athletics")
		DATA_Battle:setAct("execute")
		DATA_Battle:set( data["result"] )

		switchScene("battle")
	end

	return true , data
end

--[[竞技--战斗过程]]
function M.athletics_execute_process( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:set( data["result"] )


		-- 恢复战斗进程
		local logic =requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")-- require("GameLuaScript/Scene/battle/logicLayer")
		logic:resume("socket")
	end

	return true , data
end
--[[副本-战斗完成]]
function M.athletics_execute_finish( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		local result = data["result"]
		--结束画面用数据
		DATA_Result:set( result )
		--存储数据
--		DATA_Instance:setByKey(result["current"]["barrier_id"],"missions",result["missions"])
		
	end

	return true , data
end
--[[好友切磋/复仇-战斗开始]]
function M.friends_execute( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:setMod("friends")
		DATA_Battle:setAct("execute")
		DATA_Battle:set( data["result"] )

		switchScene("battle")
	end

	return true , data
end

--[[竞技--战斗过程]]
function M.friends_execute_process( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:set( data["result"] )


		-- 恢复战斗进程
		local logic =requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")-- require("GameLuaScript/Scene/battle/logicLayer")
		logic:resume("socket")
	end

	return true , data
end
--[[副本-战斗完成]]
function M.friends_execute_finish( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		local result = data["result"]
		--结束画面用数据
		DATA_Result:set( result )
	end

	return true , data
end


function M.rob_execute( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:setMod("rob")
		DATA_Battle:setAct("execute")
		DATA_Battle:set( data["result"] )

		switchScene("battle")
	end

	return true , data
end

--[[夺宝--战斗过程]]
function M.rob_execute_process( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:set( data["result"] )


		-- 恢复战斗进程
		local logic =requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")-- require("GameLuaScript/Scene/battle/logicLayer")
		logic:resume("socket")
	end

	return true , data
end

--[[夺宝-战斗完成]]
function M.rob_execute_finish( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		local result = data["result"]
		--结束画面用数据
		DATA_Result:set( result )
		--存储数据
--		DATA_Instance:setByKey(result["current"]["barrier_id"],"missions",result["missions"])
		
	end

	return true , data
end

--抢夺矿山
function M.mining_execute( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:setMod("mining")
		DATA_Battle:setAct("execute")
		DATA_Battle:set( data["result"] )

		switchScene("battle")
	end

	return true , data
end

--[[矿山--战斗过程]]
function M.mining_execute_process( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		DATA_Battle:set( data["result"] )


		-- 恢复战斗进程
		local logic =requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")-- require("GameLuaScript/Scene/battle/logicLayer")
		logic:resume("socket")
	end

	return true , data
end

--[[矿山-战斗完成]]
function M.mining_execute_finish( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		local result = data["result"]
		--结束画面用数据
		DATA_Result:set( result )
	end

	return true , data
end

--[[帮战-接收服务器数据]]
function M.gangbattle_get( type , data , callback )
	if type == 1 then
	elseif type == 2 then
		local scene = display.getRunningScene()
		if scene.name == "war" then
			GANG_WAR:refresh(data.result)
		end
	end

	return true , data
end
return M
