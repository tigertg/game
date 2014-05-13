--[[

战斗逻辑层

]]

local M = {}

local pause = {}    -- 战斗控制器,控制暂停与否
local cur_turn 	    -- 当前轮次
local cur_step      -- 当前步骤
local action_turn   -- 正在播放的轮次
local action_step   -- 正在播放的步骤
local layers		-- 各种层
local roundText		--战斗回合数
local handle
local selfAgent 	--存放自己一方对话者cid
local foeAgent 		--存放自己敌方对话者cid
local params 		--存放外部传入战斗的数据
local agile			--存放双方敏捷值
local rowNum = 0	--存放划动boss次数
function M:getSelfAgent()
	return selfAgent
end
function M:setSelfAgent( _cid )
	selfAgent = _cid
end
--存放双方敏捷值
function M:setAgile( _value )
	agile = _value
end
function M:getAgile()
	return agile
end
function M:getfoeAgent()
	return foeAgent
end
function M:setfoeAgent( _cid )
	foeAgent = _cid
end
-- 数据初始化
function M:init()
	pause = {}			-- 战斗控制器,控制暂停与否,可存放多个锁
	cur_turn = 1  		-- 当前轮次
	cur_step = 1  		-- 当前步骤
	action_turn = 1  	-- 正在播放的轮次
	action_step = 1  	-- 正在播放的步骤
	layers = {}		 	-- 各种层
	selfAgent = nil
	
	rowNum = 0
	
	local backHeroCell = requires(IMG_PATH,"GameLuaScript/Scene/battle/backHeroCell")
	backHeroCell:init( true )
	
	if handle ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
		handle = nil
	end
end

--返回外部附加参数
function M:getParams()
	return params
end

function M:create( _params )
	
	params = _params or {}
	
	M:init()


	local main_layer = display.newLayer()
	
	
	-- 获取战斗数据
	local report = DATA_Battle:get("report")
	
	local prepare_data = report["prepare"]


	-- 己方英雄卡牌层
	local heroLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroLayer")
	layers["selfHero"] = heroLayer:create()
	main_layer:addChild( layers["selfHero"] )
	
	--敌方英雄卡牌
	layers["enemyHero"] = display.newLayer()
	main_layer:addChild( layers["enemyHero"] )
	
	--替补英雄层
	layers["backHero"] = display.newLayer()
	main_layer:addChild( layers["backHero"] )
	layers["backHero"]:setTouchEnabled( true )
	local function onTouch( eventType , x , y )
	    if eventType == CCTOUCHBEGAN then
	    	return true
	    end
	    if eventType == CCTOUCHMOVED then return true end
	    if eventType == CCTOUCHENDED then
	    	local backHero = requires(IMG_PATH,"GameLuaScript/Scene/battle/backHeroCell")
	    	backHero:showDisseat( false )
	    	return true
	    end
	    return false
	end
	layers["backHero"]:registerScriptTouchHandler(onTouch)
	
	
	--替补英雄层
	layers["cloneHero"] = display.newLayer()
	main_layer:addChild( layers["cloneHero"] )
	

	-- 幻兽层
	local petLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/pet/petLayer")
	layers["pet"] = petLayer:create( prepare_data)
	main_layer:addChild( layers["pet"] )

	--回合数层
	layers["round"] = display.newLayer()
	local tempRoundText = display.strokeLabel("/10   回合" , 0 , 0 , 18 , ccc3(0xff , 0xff , 0xff ) , 2 , ccc3(0x34 , 0x1f , 0x0c) )
	display.align(tempRoundText , display.TOP_LEFT , 40 , 820 )
	layers["round"]:addChild( tempRoundText )
	
	roundText = display.strokeLabel("00" , 0 , 0 , 18 , ccc3(0xff , 0xff , 0xff ) , 2 , ccc3(0x34 , 0x1f , 0x0c) )
	display.align(roundText , display.TOP_LEFT , 20 , 820 )
	layers["round"]:addChild( roundText )
	main_layer:addChild( layers["round"] )
	
	-- 特效层
	local effectLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/effectLayer")
	layers["effect"] = effectLayer:create( prepare_data )
	main_layer:addChild( layers["effect"] )
	
	--四星五星技能 宠物技能 展示层
	layers["skillAction"] = heroLayer:create()
	main_layer:addChild( layers["skillAction"] )
	
	--[[开始循环战斗逻辑]]
	M:begin()


    return main_layer
end

--四星五星技能释放时控制层
function M:skillHide( isShow )

	layers["backHero"]:setVisible( isShow )
	layers["enemyHero"]:setVisible( isShow )
	
	layers["selfHero"]:setVisible( isShow )
	layers["pet"]:setVisible( isShow )
	layers["round"]:setVisible( isShow )
	
	local sceneBgLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/scene")
	sceneBgLayer:skillHide( isShow )
end

--[[战斗开始]]
function M:begin()
	-- 游戏定时器, 0.1秒触发一次
	local function tick()
		local pause_num = table.nums(pause)

		-- 判断是否暂停状态
		local step_continue = false
		if pause_num > 1 then return end
		if pause_num == 1 and pause["end"] == nil then return end

		-- 展示下一步 (如果已结束，就不再执行下一步了)
		local ret = false
		if pause["end"] == nil then
			 ret = M:next()
		end
		
		-- 判断战斗是否结束
		if ret == false then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
			handle = nil

			-- 显示结果页面
			echoLog("BATTLE" , "End , Winner is " .. DATA_Battle:get("win"))


			local function showResult( )
				local resultLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/resultLayer")
				local scene = display.getRunningScene()
				scene:addChild( resultLayer:create( ) )
			end

			-- 判断是否是假数据（新手引导）
			if DATA_Battle:getMod() == "guide" then
				showResult()
				return
			end
			
			
			-- 正常情况下，发包给后台，获取战斗结果
			local battle_call_data = {
				report_id = DATA_Battle:get("report_id"),
				num = rowNum == 0 and nil or rowNum
			}
			print("****************************** logic finish")
			
--			local resultLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/resultLayer")
--			resultLayer:mission_result()
--			showResult()
			
			SOCKET:getInstance("battle"):call( DATA_Battle:getMod() , DATA_Battle:getAct() .. "_finish" , "finish" , battle_call_data , { success_callback = showResult } )
		end
	end

	-- 触发定时器
	handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(tick , 0.02 , false)
end
function M:bossRowNum( value )
	rowNum = value
end

--[[暂停]]
function M:pause( id )
	id = id or "normal"
	
	pause[id] = true
end


--[[恢复]]
function M:resume( id )
	id = id or "normal"

	if isset(pause , id) then
		pause[id] = nil
	end
end

--[[下一步]]
function M:next()
	local step_data = DATA_Battle:getStep(cur_turn , cur_step)
	
	if step_data == nil then
		-- 如果已经是第三个回合了，证明整个战斗结束了
		if cur_turn == 3 then return false end

		-- 否则的话，再往后面找一步
		cur_turn = cur_turn + 1
		cur_step = 1

		return M:next()
	end
	
	-- 记录正在播放的步骤
	action_turn = cur_turn
	action_step = cur_step
	echoLog("BATTLE" , "turn: " .. action_turn .. " , step: " .. action_step .. " , type: " .. step_data["type"])

	-- 停止战斗，等待回调
	local step_type = step_data["type"]
	if step_type == "skip" then
		-- 跳过
	else
		M:pause()
		local step_action = requires(IMG_PATH,"GameLuaScript/Scene/battle/step/" .. step_type)
		step_action:run( step_data["type"] , step_data["data"] )
		
		--改变战斗节奏
		local notExistDelay = { 
								ignore ="ignore" ,
								sort ="sort" ,
								talk ="talk" ,
								turn ="turn" ,
								round ="round" ,
							}
		
		if not notExistDelay[ step_type .. "" ] then
			M:pause("delay")
			local handler
			local function delayRealize()
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handler)
				handler = nil
				M:resume("delay")
			end
			handler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(delayRealize , 0.5 , false)
		end
	end


	-- 计数到下一步
	cur_step = cur_step + 1

	return true
end


function M:getActionTurn()
	return action_turn
end

function M:getActionStep()
	return action_step
end


--[[获取对应层]]
function M:getLayer(name)
	return layers[name]
end
--设置回合数
function M:setRound( _str )
	roundText:setString( _str < 10 and "0".._str or _str)
end


return M
