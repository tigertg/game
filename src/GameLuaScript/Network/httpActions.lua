--[[

所有 socket 通信发送前以及回调

]]


local M = {}

--[[验证]]
function M.verify_check( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		-- 回调处理
		local result = data["result"]
		
		local session_data = result["session"]

		-- 存储数据!~
		if session_data ~= nil then
			DATA_Session:set({ uid = session_data["uid"] , sid = session_data["sid"] , server_id = session_data["server_id"] })
		end

		-- 执行成功回调
		callback(data)

		switchScene("servers" , result)
	end

	return true , data
end

--[[登录]]
function M.login_develop( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		-- 回调处理
		local result = data["result"]

		local session_data = result["session"]

		-- 存储数据!~
		if session_data ~= nil then
			DATA_Session:set({ uid = session_data["uid"] , sid = session_data["sid"] , server_id = session_data["server_id"] })
		end

		-- 执行成功回调
		callback(data)

		-- 判断是否是新号
		if isset(result , "new_open_id") then
			-- 跳转到注册页面
			switchScene("newguy" , {open_id = result["open_id"]})
		else
			-- 登录成功后，尝试连接长连接服务器
			SOCKET:getInstance("battle"):call("log" , "in" , "login" , {} , {
				success_callback = function()
					-- KNGuide:setStep( 3500 )	-- 新手引导
					-- 登录成功后，跳转到首页
					switchScene("home")
				end
			})
		end
	end

	return true , data
end

--[[登录]]
function M.login_quick( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		return M.login_develop( type , data , callback )
	end

	return true , data
end

--[[注册]]
function M.login_reg( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		-- 回调处理
		local result = data["result"]

		
		-- 登录成功后，尝试连接长连接服务器
		SOCKET:getInstance("battle"):call("log" , "in" , "login" , {} , {
			success_callback = function()
				KNGuide:setStep( 100 )	-- 新手引导

				-- 登录成功后，跳转到首页
				switchScene("home")
			end
		})

		-- 执行成功回调
		callback(data)
	end

	return true , data
end

function M.pay_callback( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		-- 回调处理
	end

	return true , data
end


--[[wap]]
function M.wap_getid( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		-- 回调处理
		switchScene("wapid")
	end

	return true , data
end


function M.wap_set( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		-- 回调处理
		switchScene("home" , {} , function()
			KNMsg:getInstance():flashShow("保存wap游戏id成功")
		end)
	end

	return true , data
end

--[[发送世界聊天]]
function M.chat_sendworld( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		if callback ~= nil then
			callback(data)
		end
	end
	return true , data
end

function M.mission_get( type , data , callback )
	if type == 1 then
	else
		local result = data["result"]
		DATA_Mission:set(result["current"]["map_id"],result)
		callback()
	end
	return true , data
end

function M.mission_cleanup_start(type, data, callback)
	if type == 1 then
	else
		DATA_Mission:setByKey("cleanup", data["result"]["cleanup"])
		callback()
	end
	return true, data
end

function M.mission_cleanup_cancel(type, data, callback)
	if type == 1 then
	else
		DATA_Mission:setByKey("cleanup", {})
		callback()
	end
	return true, data
end

function M.mission_cleanup_subtime(type, data, callback)
	if type == 1 then
	else
		DATA_Mission:setByKey("cleanup",data["result"]["cleanup"])
		callback()
	end
	return true, data
end

function M.mission_cleanup(type, data, callback)
	if type == 1 then
	else
		local result = data["result"]
		DATA_Mission:setData(result["current"]["map_id"], "missions", result["current"]["mission_id"], result["missions"][1])
		DATA_Mission:setByKey("cleanup", {})
		DATA_Result:set( result )
		callback(result["current"]["map_id"])
	end
	return true, data
end

function M.inshero_get(type , data , callback)
	if type == 1 then
	else
		DATA_Instance:set("hero",data["result"])
		callback()
	end
	return true , data
end


function M.insheronewnew_get(type , data , callback)
	if type == 1 then
	else
		DATA_Instance:set("hero",data["result"])
		callback()
	end
	return true , data
end

--抽签
function M.insheronewnew_draw(type , data , callback)
	if type == 1 then
	else
		DATA_Instance:set("hero",data["result"]["get"])
		callback()
	end
	return true , data
end

--兑换英雄
function M.insheronewnew_exchange(type , data , callback)
	if type == 1 then
	else
		DATA_Instance:set("hero",data["result"]["get"])
		callback(data["result"]["awards"]["drop"][1])
	end
	return true , data
end

--更改签面
function M.insheronewnew_alter(type , data , callback)
	if type == 1 then
	else
		DATA_Instance:set("hero",data["result"]["get"])
		callback()
	end
	return true , data
end

function M.inshero_refresh(type , data , callback)
	if type == 1 then
	else
		DATA_Instance:set("hero","current_award", data["result"]["current_award"])
		callback()
	end
	return true , data
end


function M.inspet_refresh(type , data , callback)
	if type == 1 then
	else
		DATA_Instance:set("pet","current_award", data["result"]["current_award"])
		callback()
	end
	return true , data
end

function M.inspetnew_get(type , data , callback)
	if type == 1 then
	
	else
		DATA_Instance:set("pet","instance",data["result"]["instance"])
--		DATA_Instance:set("pet","message", data["result"]["message"])
		callback()
	end
	return true , data
end

function M.inspetnew_finish(type , data , callback)
	if type == 1 then
	
	else
		DATA_Instance:set("pet", "instance",data["result"]["get"]["instance"])
		for k, v in pairs(data["result"]["message"]) do
			if string.find(k, "last") then
				DATA_Instance:setPetFb("message", k, v)
			else
				DATA_Instance:addPetArray("message", k, v)	
			end
		end
		callback()
	end
	return true , data
end

function M.insequip_get(type , data , callback)
	if type == 1 then
	else
		for k, v in pairs(data["result"]) do
			if k ~= "instance" then
				DATA_Instance:set("equip", k, v)
			else
				DATA_Instance:set("equip", tonumber(data["result"]["current_map"]), v)
			end
		end
		callback(data["result"])
	end
	return true , data
end

function M.insequip_dig(type, data, callback)
	if type == 1 then
	else
		local result = data["result"]
		DATA_Instance:set("equip", result["map_id"],25, result["boss_data"])
		callback(result["awards"])
	end
	return true, data
end

function M.insequip_openbox(type, data, callback)
	if type == 1 then
	else
		for k, v in pairs(data["result"]["get"]) do
			if k ~= "instance" then
				DATA_Instance:set("equip", k, v)
			else
				DATA_Instance:set("equip", data["result"]["get"]["current_map"], v)
			end
		end
		callback(data["result"]["awards"])
	end
	return true, data
end


function M.insequip_useshu(type, data, callback)
	if type == 1 then
	else
		DATA_Instance:set("equip", "point", data["result"]["get"]["point"])
		callback()
	end
	return true, data
end

function M.insskill_get(type, data, callback)
	if type == 1 then
	else
		DATA_Instance:set("skill",data["result"])
		callback()
	end
	return true, data
end

function M.insskill_buypoint(type, data, callback)
	if type == 1 then
	else
		DATA_Instance:set("skill",data["result"]["get"])
		callback()
	end
	return true, data
end


function M.insskill_refresh(type, data, callback)
	if type == 1 then
	else
		DATA_Instance:set("skill",data["result"]["get"])
		callback()
	end
	return true, data
end


function M.insskill_roll(type, data, callback)
	if type == 1 then
	else
		DATA_Instance:set("skill",data["result"]["get"])
		callback(data["result"])
	end
	return true, data
end

function M.formation_get(type , data , callback)
	if type == 1 then

	else
		local result = data["result"]

		DATA_Formation:set(result)
		callback()
	end
	return true , data
end

function M.formation_doset(type , data , callback )

	if type ==1 then

	else
		--if data["code"] == 0 then
			-- DATA_General:insert(data["result"]["formation_detail"])
			--DATA_Formation:set(data["result"]["_G_formation"])
		callback()
		--end
	end
	return true ,data
end

function M.formation_up(type , data , callback)
	if type ==1 then

	else
		--if data["code"] == 0 then
			-- DATA_Formation:set(data["result"]["_G_formation"])
			-- DATA_General:insert(data["result"]["formation_detail"])
			--DATA_Formation:set(data["result"]["_G_formation"])
			callback()
		--end
	end
	return true ,data
end

function M.wash_get(type , data , callback)
	if type == 1 then

	else
			local result = data["result"]
			DATA_Wash:set(result)
			callback()
	end
	return true,data
end

function M.wash_wash(type , data , callback)
	if type == 1 then

	else
		local result = data["result"]
		DATA_Wash:set(result)
		callback()
	end
	return true,data
end

function M.wash_save(type , data , callback)
	if type == 1 then

	else
			--local result = data["result"]
			--DATA_Wash:set(result)
			callback()
	end
	return true,data
end

function M.general_get(type, data, callback)
	if type == 1 then
	else
		callback()
	end
	return true, data
end
--武将传功
function M.general_transmission(type, data, callback)
	if type == 1 then
	else
		callback(data)
	end
	return true, data
end
--武将升阶
function M.general_upgrade(type, data, callback)
	if type == 1 then
	else
		callback()
	end
	return true, data
end

function M.pet_get(type, data, callback)
	if type == 1 then
	else
		callback()
	end
	return true,data
end

--设置宠物上阵
function M.pet_seton(type,data,callback)
	if type == 1 then
	else
		if data["code"] == 0 then
			callback()
		end
	end
	return true,data
end

--丢弃宠物
function M.pet_abandon(type,data,callback)
	if type == 1 then
	else
		if data["code"] == 0 then
			callback()
		end
	end
	return true,data
end

--孵化状态
function M.pet_get_hatch(type, data, callback)
	if type == 1 then
	else
		DATA_Hatch:set(data["result"])
		callback()
	end
	return true, data
end

--取消孵化
function M.pet_cancel_hatch(type, data, callback)
	if type == 1 then
	else
		DATA_Hatch:upData(data["result"]["incubator"])
	
		callback()
	end
	return true, data
end

--孵化完成
function M.pet_hatch_complete(type, data, callback)
	if type == 1 then
	else
		DATA_Hatch:upData(data["result"]["incubator"])
	
		callback( data )
	end
	return true, data
end
--孵化完成(一键收取)
function M.pet_onekey_complete(type, data, callback)
	if type == 1 then
	else
		DATA_Hatch:upData(data["result"]["incubator"])
	
		callback( data )
	end
	return true, data
end
--孵化加速
function M.pet_hatch_acce(type, data, callback)
	if type == 1 then
		
	else
		DATA_Hatch:upData(data["result"]["incubator"])
		callback()
	end
	return true, data
end

--开启孵化位
function M.pet_add_hatch(type, data, callback)
	if type == 1 then
	else
		DATA_Hatch:upData(data["result"]["incubator"])
		callback()
	end
	return true, data
end
--开始孵化
function M.pet_set_hatch(type, data, callback)
	if type == 1 then
	else
		DATA_Hatch:upData(data["result"]["incubator"])
	
		callback()
	end
	return true, data
end

function M.pet_merge(type,data,callback)
	if type == 1 then
	else
		callback(data)
	end
	return true,data
end

function M.pet_feed(type,data,callback)
	if type == 1 then
	else
		callback()
	end
	return true,data
end

function M.shop_get(type, data, callback)
	if type == 1 then
	else
		DATA_Shop:set(data["result"])
		callback(data)
	end
	return true, data
end

function M.shop_buy(type, data, callback)
	if type == 1 then
	else
		callback(data)
	end
	return true, data
end

function M.equip_get(type, data, callback)
	if type == 1 then
	else
--		DATA_Equip:insert(data["result"]["equip"])
		callback(data)
	end
	return true, data
end
--英雄换装
function M.equip_dress(type, data, callback)
	if type == 1 then
	else
		DATA_ROLE_SKILL_EQUIP:set(data["result"]["_G_general_dress"])
		callback(data)
	end
	return true, data
end
--英雄换技能
function M.skill_dress(type, data, callback)
	if type == 1 then
	else
		DATA_ROLE_SKILL_EQUIP:set(data["result"]["_G_general_dress"])
		callback(data)
	end
	return true, data
end
--英雄换技能
function M.skill_petskill_dress_new(type, data, callback)
	if type == 1 then
	else
--		DATA_ROLE_SKILL_EQUIP:set(data["result"]["_G_general_dress"])
		callback(data)
	end
	return true, data
end
--技能合成
function M.skill_merge(type, data, callback)
	if type == 1 then
	else
		callback(data)
	end
	return true, data
end

function M.skill_exchange(type, data, callback)
	if type == 1 then
	else
		callback(data)
	end
	return true, data
end


function M.bag_get(type, data, callback)
	if type == 1 then
	else
		DATA_Bag:set(data["result"]["type"],data["result"]["data"])
		callback()
	end

	return true, data
end

function M.bag_sell(type, data, callback)
	if  type == 1 then
	else
		callback(data)
	end	
	return true, data
end

function M.bag_usekit(type, data, callback)
	if type == 1 then
	else
		callback(data["result"])
	end
	return true, data
end

function M.equip_equipup(type, data, callback)
	if type == 1 then
	else
		callback(data)
	end
	return true, data
end


function M.general_martial(type, data, callback)

	if type == 1 then

	else
	
		callback(data)
		
	end

	return true, data
end

function M.pulse_get(type, data, callback)

	if type == 1 then

	else
		DATA_Pulse:set(data)
		callback(data)
		
	end

	return true, data
end

function M.pulse_initial(type, data, callback)

	if type == 1 then

	else
		
		DATA_Pulse:set(data)
		callback(data)
		
	end

	return true, data
end

function M.pulse_feed(type, data, callback)

	if type == 1 then

	else
		
		DATA_Pulse:set(data)
		callback()
		
	end

	return true, data
end

function M.pulse_dig(type, data, callback)

	if type == 1 then

	else
		DATA_Pulse:set(data)
		callback()
		
	end

	return true, data
end


function M.athletics_get(type, data, callback)
	if type == 1 then
	else
		callback(data["result"])
	end
	return true,data
end

function M.athletics_add_times(type, data, callback)
	if type == 1 then
	else
		callback(data["result"])
	end
	return true, data
end

function M.athletics_refresh(type, data, callback)
	if type == 1 then
	else
		callback(data["result"])
	end
	return true, data
end


function M.athletics_award(type, data, callback)
	if type == 1 then
	else
		callback(data["result"])
	end
	return true, data
end

function M.status_get(type, data, callback)
	if type == 1 then
	else
		callback({rank = data["result"]["athletics_rank"], ability = data["result"]["ability"] , gang = data["result"]["alliance"] })
	end
	return true, data
end

function M.status_eat(type, data, callback)
	if type == 1 then
	else
		callback(data)
	end
	return true, data
end

function M.ranking_get(type, data, callback)
	if type == 1 then
	else
		callback()
	end
	return true, data
end
--[[发送消息]]
function M.message_talk(type, data, callback)
	if type == 1 then
	else
		callback()
	end
	return true, data
end

function M.message_get(type, data, callback)
	if type == 1 then
	else
		DATA_Info:set(data["result"])
		callback()
	end
	return true, data
end
--在线礼包数据获取
function M.olgift_get(type , data , callback)
	if type == 1 then
	else
		callback()
	end
	return true,data
end
--在线礼包领取
function M.olgift_receive(type , data , callback)
	if type == 1 then
	else
		callback()
	end
	return true,data
end
--新手成就礼包数据获取
function M.achievegift_get(type , data , callback)
	if type == 1 then

	else
		DATA_Olgift:set_type("achievegift" , data["result"] )
		callback()
	end
	return true,data
end

--新手成就礼包领取
function M.achievegift_receive(type , data , callback)
	if type == 1 then

	else
		DATA_Olgift:set_type("achievegift" , data["result"]["get"] )
		callback()
	end
	return true,data
end

function M.soul_get(type, data, callback)
	if type == 1 then
	else
		callback(data["result"]["_G_soul"])
	end
	return true, data
end

function M.soul_dismantling(type, data, callback)
	if type == 1 then
	else
		callback(data["result"]["_G_soul"], data["result"].stone)
	end
	return true, data
end

function M.soul_fuse(type, data, callback)
	if type == 1 then
	else
		local id
		for k, v in pairs(data["result"]["_U_bag"]["general"]) do
			id = k 
		end
		callback(data["result"]["_G_soul"],id)
	end
	return true, data
end


function M.soul_directionalfuse(type, data, callback)
	if type == 1 then
	else
		local id
		for k, v in pairs(data["result"]["_U_bag"]["general"]) do
			id = k 
		end
		callback(data["result"]["_G_soul"],id)
	end
	return true, data
end


function M.equippieces_get(type, data, callback)
	if type == 1 then
	else
		callback(data["result"]["_G_chip"])
	end
	return true, data
end

function M.equippieces_dismantling(type, data, callback)
	if type == 1 then
	else
		callback(data["result"]["_G_chip"])
	end
	return true, data
end



function M.equippieces_fuse(type, data, callback)

	if type == 1 then
	else
		local id
		for k, v in pairs(data["result"]["_U_bag"]["equip"]) do
			id = k 
		end
		callback(data["result"]["_G_chip"],id)
	end
	return true, data
end



function M.animalsoul_get(type, data, callback)
	if type == 1 then
	else
		callback(data["result"]["_G_animal"])
	end
	return true, data
end


function M.animalsoul_dismantling(type, data, callback)
	if type == 1 then
	else
		callback(data["result"]["_G_animal"])
	end
	return true, data
end



function M.animalsoul_fuse(type, data, callback)
	if type == 1 then
	else
		local id
		for k, v in pairs(data["result"]["_U_bag"]["pet"]) do
			id = k 
		end
		callback(data["result"]["_G_animal"],id)
	end
	return true, data
end

function M.pulse_merge(type, data, callback)
	if type == 1 then
	else
		callback()
	end
	return true, data
end

function M.pet_merge1(type, data, callback)
	if type == 1 then
	else
		callback()
	end
	return true, data
end
--查看其它玩家基本信息
function M.profile_get(type, data, callback)
	if type == 1 then
	else
		DATA_OTHER:set_type( "base" , data["result"] )
		callback()
	end
	return true, data
end
--查看其它玩家阵法信息
function M.profile_getuidformation(type, data, callback)
	if type == 1 then
	else
		DATA_OTHER:set_type( "formation" , data["result"] )
		callback()
	end
	return true, data
end
--查看其它玩家阵法信息
function M.pet_hatch(type, data, callback)
	if type == 1 then
	else
		callback( data["result"] )
	end
	return true, data
end

function M.skill_heroskill_up(type, data, callback)
	if type == 1 then
	else
		callback( data["result"] )
	end
	return true, data
end

function M.skill_petbagskill_up(type, data, callback)
	if type == 1 then
	else
		callback( data["result"] )
	end
	return true, data
end

function M.skill_petnatskill_up(type, data, callback)
	if type == 1 then
	else
		callback( data["result"] )
	end
	return true, data
end

function M.pet_upgrade(type, data, callback)
	if type == 1 then
	else
		msg = data["msg"]
		callback()
	end
	return true, data
end







--活动入口
function M.activity_get(type , data , callback)
	if type == 1 then

	else
		DATA_Activity:set_type( data["result"] )
		callback()
	end
	return true,data
end
--连续登陆领奖
function M.activity_receive_login(type , data , callback)
	if type == 1 then

	else
		M.inform( data["result"] )
		DATA_Activity:set_type( data["result"] )
		callback()
	end
	return true,data
end

--好汉目标活动
function M.activity_receive_achieve(type , data , callback)
	if type == 1 then

	else
		M.inform( data["result"] )
		DATA_Activity:set_type( data["result"] )
		callback()
	end
	return true,data
end
--升级活动
function M.activity_receive_lvup(type , data , callback)
	if type == 1 then

	else
		M.inform( data["result"] )
		DATA_Activity:set_type( data["result"] )
		callback()
	end
	return true,data
end
--对酒活动
function M.activity_receive_wine(type , data , callback)
	if type == 1 then

	else
		M.inform( data["result"] )
		DATA_Activity:set_type( data["result"] )
		callback()
	end
	return true,data
end
--充值奖励活动
function M.activity_receive_payment(type , data , callback)
	if type == 1 then

	else
		M.inform( data["result"] )
		DATA_Activity:set_type( data["result"] )
		callback()
	end
	return true,data
end
--首充礼包
function M.activity_receive_firstpay(type , data , callback)
	if type == 1 then

	else
		M.inform( data["result"] )
		DATA_Activity:set_type( data["result"] )
		callback()
	end
	return true,data
end
--五星英雄
function M.activity_receive_singlepaymax(type , data , callback)
	if type == 1 then

	else
		M.inform( data["result"] )
		DATA_Activity:set_type( data["result"] )
		callback()
	end
	return true,data
end
--全民福利
function M.activity_receive_welfare(type , data , callback)
	if type == 1 then

	else
		M.inform( data["result"] )
		DATA_Activity:set_type( data["result"] )
		callback()
	end
	return true,data
end

--超值兑换
function M.activity_receive_xchange(type , data , callback)
	if type == 1 then

	else
		dump( data["result"] )
		M.inform( data["result"] )
		DATA_Activity:set_type( data["result"] )
		callback()
	end
	return true,data
end

function M.iapppay_token(type , data , callback)
	if type == 1 then

	else
		callback(data["result"])
	end
	return true,data
	
end

function M.rob_get(type, data, callback)
	if type == 1 then
	else
		callback(data["result"])
	end
	return true, data
end

function M.rob_getlist(type, data, callback)
	if type == 1 then
	else
		callback(data["result"]["list"])	
	end
	return true, data
end
--获取帮派数据
function M.alliance_get(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set( data["result"] )
		callback()
	end
	return true,data
end
--获取其它帮派排行数据
function M.alliance_rank(type , data , callback)
	if type == 1 then
	else
		if data["result"]["apply"] then
			DATA_Gang:set_type( "apply" , data["result"]["apply"] )
			data["result"]["apply"] = nil
		end
		
		DATA_Gang:set_type( "rank" , data["result"] )
		callback()
	end
	return true,data
end
--创建帮派
function M.alliance__create(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set( data["result"] )
		callback()
	end
	return true,data
end
--申请加入帮派
function M.alliance_application(type , data , callback)
	if type == 1 then
	else
		if data["result"].info  then
			DATA_Gang:set_type( "info" , data["result"].info )
			DATA_Gang:set_type( "list" , data["result"].list )
		else
			DATA_Gang:set_type( "apply" , data["result"]["apply"] )
		end
		callback()
	end
	return true,data
end
--取消帮派申请
function M.alliance_exitapplication(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set_type( "apply" , data["result"] )
		callback()
	end
	return true,data
end

--查看其它帮派详细信息
function M.alliance_getallianceinfo(type , data , callback)
	if type == 1 then
	else
		callback( data["result"] )
	end
	return true,data
end
--编辑公告
function M.alliance_notice(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set( data["result"] )
		callback( data["result"] )
	end
	return true,data
end
--踢人、退出
function M.alliance_excluding(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set_type("info" ,  data["result"].info )
		DATA_Gang:set_type("list" ,  data["result"].list )
		callback( data["result"] )
	end
	return true,data
end
--加入帮派后帮派列表
function M.alliance_totalrank(type , data , callback)
	if type == 1 then
	else
		--rank   总榜
		--rank_top   总榜排名
		--ability   战力
		--ability_top   战力排行数
		--tribute   帮威
		--tribute_top   帮威排行
		DATA_Gang:set_type( "gang_rank" , data["result"] )
		callback( )
	end
	return true,data
end
--加入帮派后帮派列表
function M.alliance_eventmovement(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set_type( "event_movement" , data["result"].event_movement )
		callback( )
	end
	return true,data
end

--帮派祈福界面数据
function M.alliance_clifford(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set_type( "pray" , data["result"] )
		callback( )
	end
	return true,data
end
--帮派祈福界面数据
function M.alliance_sendclifford(type , data , callback)
	if type == 1 then
	else
		
		local tempData = DATA_Gang:get("pray")
		tempData = tempData or {}
		tempData.rands = data["result"].rands
		DATA_Gang:set_type( "pray" , tempData )
		
		callback(data["result"] )
	end
	return true,data
end
--祈福动态信息
function M.alliance_cliffordmovement(type , data , callback)
	if type == 1 then
	else
		callback(data["result"] )
	end
	return true,data
end

--帮派收人数据
function M.alliance_fresh(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set_type( "applylist" , data["result"].applylist )
		callback( )
	end
	return true,data
end
--帮派拒绝申请者加入
function M.alliance_refuse(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set_type( "applylist" , data["result"].applylist )
		callback( )
	end
	return true,data
end
--帮派一键拒绝申请者加入
function M.alliance_refuseonekey(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set_type( "applylist" , data["result"].applylist )
		callback( )
	end
	return true,data
end
--帮派 申请同意
function M.alliance_agree(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set_type( "info" , data["result"].info )
		DATA_Gang:set_type( "list" , data["result"].list )
		DATA_Gang:set_type( "applylist" , data["result"].applylist )
		callback( )
	end
	return true,data
end
--帮派一键同意
function M.alliance_agreeonekey(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set_type( "info" , data["result"].info )
		DATA_Gang:set_type( "list" , data["result"].list )
		DATA_Gang:set_type( "applylist" , data["result"].applylist )
		callback( )
	end
	return true,data
end
--帮派任命
function M.alliance_manage(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set_type( "info" , data["result"].info )
		DATA_Gang:set_type( "list" , data["result"].list )
		callback( )
	end
	return true,data
end
--帮派升级
function M.alliance_escalate(type , data , callback)
	if type == 1 then
	else
		if data["result"].info then
			DATA_Gang:set_type( "info" , data["result"].info )
			DATA_Gang:set_type( "list" , data["result"].list )
		else
			DATA_Gang:set_type( "gangup" , data["result"] )
		end
		callback( )
	end
	return true,data
end
--帮派任务捐献
function M.alliance_task(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set_type( "task" , data["result"] )
		callback( )
	end
	return true,data
end
--确认捐献
function M.alliance_senddonate(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set_type( "info" , data["result"].info )
		DATA_Gang:set_type( "list" , data["result"].list )
		if data["result"].donate then
			local tempData = DATA_Gang:get( "task" )
			tempData.donate = data["result"].donate
			DATA_Gang:set_type( "task" ,tempData )
		end
		
		if data["result"].task then
			local tempData = DATA_Gang:get("task") or {}
			tempData.task = data["result"].task
			DATA_Gang:set_type( "task" , tempData )
		end 
		
		callback( )
	end
	return true,data
end
--重置任务
function M.alliance_resettask(type , data , callback)
	if type == 1 then
	else
		local tempData = DATA_Gang:get("task") or {}
		tempData.task = data["result"].task
		DATA_Gang:set_type( "task" , tempData )
		callback( )
	end
	return true,data
end
--执行任务
function M.alliance_posttask(type , data , callback)
	if type == 1 then
	else
		local tempData = DATA_Gang:get("task") or {}
		tempData.task = data["result"].task
		
		DATA_Gang:set_type( "task" , tempData )
		DATA_Gang:set_type( "info" , data["result"].info )
		DATA_Gang:set_type( "list" , data["result"].list )
		
		callback( )
	end
	return true,data
end
--接受任务
function M.alliance_receivetask(type , data , callback)
	if type == 1 then
	else
		local tempData = DATA_Gang:get("task") or {}
		tempData.task = data["result"].task
		DATA_Gang:set_type( "task" , tempData )
		callback( )
	end
	return true,data
end
--帮会自动加人与验证加人切换
function M.alliance_switchuser(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set_type( "applylist" , data["result"].applylist )
		DATA_Gang:set_type( "list" , data["result"].list )
		callback( )
	end
	return true,data
end
--帮会商城
function M.alliance_shop(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set_type( "shop" , data["result"] )
		callback( )
	end
	return true,data
end
--开启帮会宝石加成
function M.alliance_wakeprop(type , data , callback)
	if type == 1 then
	else
		
		local tempData = DATA_Gang:get("shop")
		tempData.gemconfig = data["result"].gemconfig
		DATA_Gang:set_type( "shop" , tempData )
		
		DATA_Gang:set_type( "info" , data["result"].info )
		DATA_Gang:set_type( "list" , data["result"].list )
		callback( )
	end
	return true,data
end
--开启帮会宝石购买
function M.alliance_shopprop(type , data , callback)
	if type == 1 then
	else
		DATA_Gang:set_type( "info" , data["result"].info )
		DATA_Gang:set_type( "list" , data["result"].list )
		callback( )
	end
	return true,data
end

function M.message_get_wajue(type , data , callback)
	if type == 1 then
	else
		local result = data["result"]["_G_message_wajue"]
		callback(result[#result])
	end
	return true,data
end


--读取帮派聊天数据
function M.alliance_getchat(type , data , callback)
	if type == 1 then
	else
		DATA_Info:set_type("gang",data["result"])
		callback()
	end
	return true,data
end
--发送帮派聊天
function M.alliance_sendchat(type , data , callback)
	if type == 1 then
	else
		callback()
	end
	return true,data
end
--读取好友聊天数据
function M.message_get_siliao(type , data , callback)
	if type == 1 then
	else
		DATA_Info:set_type( "friend" , data["result"]._G_message_siliao )
		callback()
	end
	return true,data
end
--发送好友聊天数据
function M.message_siliao(type , data , callback)
	if type == 1 then
	else
		callback()
	end
	return true,data
end
--获取世界聊天数据
function M.message_gettalk(type, data, callback)
	if type == 1 then
	else
		DATA_Info:set_type("_G_message_talk" , data["result"]._G_message_talk )
		callback()
	end
	return true, data
end
--刷新幻兽技能
function M.pet_rand_skill(type , data , callback)
	if type == 1 then
	else
		callback(data["result"])
	end
	return true,data
end

--刷新幻兽技能
function M.pet_save_skill(type , data , callback)
	if type == 1 then
	else
		callback(data["result"])
	end
	return true,data
end
--获取vip配置信息
function M.vip_get(type , data , callback)
	if type == 1 then
	else
		DATA_Vip:set_type( "vip" , data["result"] )
		callback()
	end
	return true,data
end
function M.vip_receive(type , data , callback)
	if type == 1 then
	else
		DATA_Vip:set_type( "vip" , data["result"].get )
		callback()
		switchScene("vip" , {} , function()
			M.inform( data["result"] )
		end)
	end
	return true,data
end

function M.evolvepool_merge(type, data, callback)
	if type == 1 then
	else
		--传物品的id与cid
		callback(data["result"]["id"], data["result"]["awards"]["drop"][1])
	end
	
	return true, data
end

--使用vip礼包
function M.bag_usevipkit(type, data, callback)
	if type == 1 then
	else
		--传物品的id与cid
		callback(data["result"],M.inform)
	end
	
	return true, data
end

--使用vip礼包
function M.bag_usev3card(type, data, callback)
	if type == 1 then
	else
		dump(data)
		callback()
	end
	
	return true, data
end

--使用祝福礼包
function M.bag_usezhufukit(type, data, callback)
	if type == 1 then
	else
		--传物品的id与cid
		callback(data["result"],M.inform)
	end
	
	return true, data
end

function M.penglai_rand(type, data, callback)
	if type == 1 then
	else
		
		callback(data["result"])
	end
	
	return true, data
end


function M.penglai_get(type, data, callback)
	if type == 1 then
	else
		--传物品的id与cid
		callback(data["result"]["_G_penglai"])
	end
	
	return true, data
end
--大于20级玩家返还活动
function M.feedback_lvgt20(type, data, callback)
	if type == 1 then
	else
		M.inform( data["result"] )
		callback()
	end
	return true, data
end
--排名100玩家返还活动
function M.feedback_rank100(type, data, callback)
	if type == 1 then
	else
		M.inform( data["result"] )
		callback()
	end
	return true, data
end
--大于20级玩家返还活动
function M.ucactivation_lvgt20(type, data, callback)
	if type == 1 then
	else
		M.inform( data["result"] )
		callback()
	end
	return true, data
end
--排名100玩家返还活动
function M.ucactivation_rank100(type, data, callback)
	if type == 1 then
	else
		M.inform( data["result"] )
		callback()
	end
	return true, data
end
--获取充值返利数据
function M.feedback_get_pay(type, data, callback)
	if type == 1 then
	else
		callback( data["result"] )
	end
	return true, data
end

--获取武将附加属性加成信息获取
function M.general_get_attr(type, data, callback)
	if type == 1 then
	else
		callback( data["result"] )
	end
	return true, data
end



--领取充值返利数据
function M.feedback_pay(type, data, callback)
	if type == 1 then
	else
		M.inform( data["result"] )
		callback()
	end
	return true, data
end
--唐门激活码领取
function M.tmsjactivation_receive(type, data, callback)
	if type == 1 then
	else
		-- 回调处理
		switchScene("home" , {} , function()
			M.inform( data["result"] )
		end)
	end
	return true, data
end
--[[uc激活码]]
function M.ucactivation_receive( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		-- 回调处理
		switchScene("home" , {} , function()
			M.inform( data["result"] )
		end)
	end

	return true , data
end
--[[官服大话激活码]]
function M.dhshjhm_receive( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		-- 回调处理
		switchScene("home" , {} , function()
			M.inform( data["result"] )
		end)
	end

	return true , data
end
--[[联运大话激活码]]
function M.dhshjhm_receive_union( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		-- 回调处理
		switchScene("home" , {} , function()
			M.inform( data["result"] )
		end)
	end

	return true , data
end
--获取好友数据
function M.friends_get( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		-- 回调处理
		DATA_Friend:set( data["result"] )
		callback( )
	end
	return true , data
end
--添加好友数据
function M.friends_addfrd( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		-- 回调处理
		KNMsg.getInstance():flashShow( "好友添加成功！" )
		DATA_Friend:set( data["result"].get )
		callback( )
	end
	return true , data
end
--删除好友
function M.friends_delfrd( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		-- 回调处理
		KNMsg.getInstance():flashShow( "删除成功！" )
		DATA_Friend:set( data["result"].get )
		callback( )
	end
	return true , data
end
--祝福好友
function M.friends_zhufu( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		-- 回调处理
		DATA_Friend:set( data["result"].get )
		if data["result"].success then
			KNMsg.getInstance():flashShow( "祝福成功！" )
		end
		callback( )
	end
	return true , data
end
--查找好友
function M.friends_search( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		-- 回调处理
		DATA_OTHER:set_type( "base" , data["result"] )
		callback()
	end
	return true , data
end
--删除仇人
function M.friends_delenermy( type , data , callback )
	if type == 1 then
		-- 发送前数据处理
	elseif type == 2 then
		-- 回调处理
		DATA_Friend:set( data["result"].get )
		callback()
	end
	return true , data
end

function M.mining_get(type, data, callback)
	if type == 1 then
	else
		callback(data["result"])
	end
	return true, data
end


function M.mining_get_list(type, data, callback)
	if type == 1 then
	else
		callback(data["result"])
	end
	return true, data
end



function M.mining_receive(type, data, callback)
	if type == 1 then
	else
		callback(data["result"])
	end
	return true, data
end
--同意保护矿山
function M.mining_guard_accept(type, data, callback)
	if type == 1 then
	else
		callback( data["result"] )
	end
	return true, data
end

function M.mining_guard_request(type, data, callback)
	if type == 1 then
	else
		callback()
	end
	return true, data
end
function M.gangbattle_enter(type, data, callback)
	if type == 1 then
	else
		callback(data["result"])
	end
	return true, data
end
function M.gangbattle_move(type, data, callback)
	if type == 1 then
	else
		dump(data)
		callback(data["result"])
	end
	return true, data
end
--累积冲值 累充大礼
function M.activity_receive_paycount(type , data , callback)
	if type == 1 then
	else
		M.inform( data["result"] )
		DATA_Activity:set_type( data["result"] )
		callback()
	end
	return true,data
end
--单充大礼
function M.activity_receive_singlepay(type , data , callback)
	if type == 1 then
	else
		M.inform( data["result"] )
		DATA_Activity:set_type( data["result"] )
		callback()
	end
	return true,data
end
--中秋登陆礼包
function M.activity_receive_logincount(type , data , callback)
	if type == 1 then

	else
		M.inform( data["result"] )
		DATA_Activity:set_type( data["result"] )
		callback()
	end
	return true,data
end









--奖励领取提示
function M.inform( data )
	dump( data )
	if data.awards then
		local str = ""
		local decollator = "    "	--分割符
		
		local function countDrop( dropData )
			local tempStr = ""
			for key , v in pairs( dropData ) do	
				local curName = getConfig( getCidType( key ) , key , "name" )
				tempStr = tempStr .. curName .. "  +" .. v .. decollator
			end
			return tempStr
		end
		local isBox = false
		for key , v in pairs( data.awards ) do
			if key == "power"		then str = str .. "体力  +" .. v
			elseif key == "gold"		then str = str .. "黄金  +" .. v
			elseif key == "silver"		then str = str .. "银币  +" .. v
			elseif key == "chip1"		then str = str .. "一星装备碎片  +" .. v
			elseif key == "chip2"		then str = str .. "二星装备碎片  +" .. v
			elseif key == "chip3"		then str = str .. "三星装备碎片  +" .. v
			elseif key == "chip4"		then str = str .. "四星装备碎片  +" .. v
			elseif key == "soul1"		then str = str .. "一星英雄将魂  +" .. v
			elseif key == "soul2"		then str = str .. "二星英雄将魂  +" .. v
			elseif key == "soul3"		then str = str .. "三星英雄将魂  +" .. v
			elseif key == "soul4"		then str = str .. "四星英雄将魂  +" .. v
			elseif key == "animal1"		then str = str .. "一星兽魂  +" .. v
			elseif key == "animal2"		then str = str .. "二星兽魂  +" .. v
			elseif key == "animal3"		then str = str .. "三星兽魂  +" .. v
			elseif key == "animal4"		then str = str .. "四星兽魂  +" .. v
			elseif key == "_tip_"		then str = str .. v isBox = true 
			elseif key == "drop"	then str = str .. countDrop( v )
			end
			str = str ..  decollator
		end
		if isBox then
			KNMsg.getInstance():boxShow( str ,{ 
												confirmText = COMMONPATH .. "confirm.png" , 
												confirmFun = function()  end , 
												} )
		else
			KNMsg.getInstance():flashShow( str )
		end
	end
end


return M


