--[[

		宠物技能按钮

]]--
local config = requires(IMG_PATH,"GameLuaScript/Config/Petskill")
local M = {}
local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local heroCell = requires(IMG_PATH , "GameLuaScript/Scene/battle/heroCell")
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
function M:create( data , param )
	if type(param) ~= "table" then param = {} end
	if type( data) ~= "table" then  data = { skill_id = "1" }  end

	local tempData = data
	data = config[ tempData.cid .. "" ][ tempData.lv .."" ]
	data.cid = tempData.cid
	data.lv = tempData.lv
	
	local isCD = false --CD时间未完成
	local imagePath = IMG_PATH .. "image/scene/battle/pet/"
	local btnTip		--CD完成提示动画
	local isFirst = true
	
	
	
	local function onTouch()
		if not isCD then
			KNMsg:getInstance():flashShow("技能尚未就绪")
			return false 
		end

		-- 判断是否是假数据（新手引导）
		if DATA_Battle:getMod() == "guide" then
--			KNMsg.getInstance():flashShow("测试战斗，不可点击")
			return
		end
			
			
		local isPerish = true	--如果有一队人员全部死亡 则直接返回
		for i = 1 , 2 do
			if isPerish then
				for j = 0 , 4 do
					if heroCell:get( i , j ) then
						isPerish = false
						break
					end
				end
			end
		end
		
		if isPerish then
			return false
		end
		
		
		
		local skill_type = tonumber(data.type) 	-- 技能类型
		local select_group = getConfig( "petskill" , data.cid , "type" ) == 5 and 1 or 2 --水系先自己一方 			-- 技能选择那一方的英雄
		local selectMask_y = getConfig( "petskill" , data.cid , "type" ) == 5 and 193 or 487 --水系先自己一方
		
		if skill_type == 5 then
			select_group = 1
			selectMask_y = 200
		end
		
		local selfPet = requires(IMG_PATH , "GameLuaScript/Scene/battle/pet/petLayer"):getPetData(1)
		if  tonumber( selfPet.power) >= tonumber( data.need_power ) then
			local selectMask = PlayerGuide:createSprite()
			local scene = display.getRunningScene()
			--发送网络请求
			local function askFun( _data )
				for i = 0 , 3 do
					local tragetHero = heroCell:get( select_group , i )
					if tragetHero then
						tragetHero:setSelectFun( nil )
					end
				end
			
				if scene:getChildByTag("899") then
					scene:removeChild(selectMask , true)
				end
				
				logic:resume("select")
				logic:pause("socket")
				
				local totalStep = ( #DATA_Battle:get("report")[ logic:getActionTurn().."" ] ) - 1
				local curStep = logic:getActionStep() - 1
				local battle_call_data = {
					report_id = DATA_Battle:get("report_id"),
					turn = logic:getActionTurn(),
					step = curStep>totalStep and totalStep or curStep ,		
					pet_skill_id = data.cid,
					target_id = _data.id or "" ,
					index = _data._index or ""
				}
				
				SOCKET:getInstance("battle"):call(DATA_Battle:getMod() , DATA_Battle:getAct() .. "_process" , "process" , battle_call_data , {
					error_callback = function(err)
						logic:resume("socket")
						logic:resume("stopPet")
						logic:resume()
						KNMsg.getInstance():flashShow("[" .. err.code .. "]" .. err.msg)	-- 弹出错误文字提示
					end,
					success_callback = function()
						param.refreshFun()
						--立刻解除提示效果加的暂停（不管是否存在）
						logic:resume("stopPet")
					end
				})
			end

			
			logic:pause("select")
			selectMask:show( 458 , 173 , ccp( 13 , selectMask_y ) , 0.7 , function()end , function()end)
			selectMask:setTag("899")
			scene:addChild(selectMask , 100 )
			
			--选择目标标题
			local selectTitleSp = display.newSprite( imagePath .. "select_title.png")
			setAnchPos( selectTitleSp , display.cx , selectMask_y + 213 , 0.5 , 0.5)
			selectMask:addChild( selectTitleSp )
			--标题装饰线
			local selectLine = display.newSprite( IMG_PATH .. "image/scene/battle/hero_info/line_long.png")
			setAnchPos( selectLine , display.cx , selectMask_y + 194 , 0.5 , 0.5)
			selectMask:addChild( selectLine )
				
			
			for i = 0 , 3 do
				local tragetHero = heroCell:get( select_group , i )
				if tragetHero then
					tragetHero:setSelectFun( askFun )
				end
			end
			
		else
			logic:resume("stopPet")
			logic:resume("socket")
			logic:resume()
			KNMsg:getInstance():flashShow("当前剩余活力值" .. selfPet.power  .. "    该技能需要消耗活力值 " .. data.need_power .. "\n请及时喂养幻兽！")
		end
		
		if btnTip then
			btnTip:removeFromParentAndCleanup(true)	-- 清除自己
			btnTip = nil
			isFirst = true
		end
		
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	local layer = display.newLayer()
	
	--技能图标
	local skillImage = KNBtn:new( IMG_PATH .. "image/skill/" , {data.cid .. ".png"} , -30 , -30 , { 
			front = IMG_PATH .. "image/skill/" .. data.cid .. ".png" , 
			frontScale = { 1.1 } , 
			callback = onTouch ,
	} )
	layer:addChild( skillImage:getLayer() )


	-- 前景mask图片
	local maskImage = display.newSprite( imagePath .. "skill_fore.png")
	layer:addChild( maskImage )

----------------------------------------------------------------------------------------------------------
--
--	静态画面相关
--
	--静止画面CD时间效果
	--背景


	local staticBg = display.newSprite(imagePath .. "static_bg.png")
	layer:addChild(staticBg)


	--静止画面CD时间效果
	local staticEff = display.newSprite( imagePath .. "skill_fore.png" )
	
	local function staticOverFun()
		if isCD then
			
			staticBg:setVisible(false)	--隐藏当前静止画面
			staticEff:setVisible(false)
			--效果动画
			local function delayFun()
					local handler
					local function delayRealize()
						CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handler)
						handler = nil
						logic:resume("stopPet")
					end
					handler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(delayRealize , 0.3 , false)
			end

			
			local function tipEff()
				local frames = display.newFramesWithImage( imagePath .. "click_tip.png" , 6 )
				 
				btnTip = display.playFrames(
					newX , newY, 
					frames,
					0.15,
					{
						delay = 0.05,
						onComplete = function()
							btnTip:removeFromParentAndCleanup(true)	-- 清除自己
							if isFirst then
								isFirst = false
								delayFun()
							end
							if isCD then
								tipEff()
							end
						end
					}
				)
				btnTip:setAnchorPoint( ccp(0.5 , 0.5) )
				-- 添加到 特效层
				layer:addChild( btnTip )
			end
			--敌方不显示点击动画效果
			if  param.isSelf then
				tipEff()
			else
				delayFun()
			end
		else
			staticBg:setVisible(true)	
			staticEff:setVisible( true )
		end
	end


    local cdTime = CCProgressTimer:create(staticEff)
    cdTime:setType(kCCProgressTimerTypeRadial)
	layer:addChild(cdTime)

	local to1 = CCProgressTo:create(0 , 0)
	cdTime:runAction(transition.sequence({to1 , CCCallFunc:create(staticOverFun)}))
	local function skillTip()
		
	end
	--CD时间进度计算
	function layer:setCurValue( num )
		if num >= math.floor( data.max_sp ) then
			num = data.max_sp
			if not isCD then
				isFirst = true
				logic:pause("stopPet")
				to1 = CCProgressTo:create( 0.5 , num / data.max_sp * 100)
				cdTime:runAction(transition.sequence({to1 , CCCallFunc:create(staticOverFun)  }))
			end
			isCD = true
		else
			isCD = false
			to1 = CCProgressTo:create( 0.5 , num / data.max_sp * 100)
			cdTime:runAction(transition.sequence({to1 , CCCallFunc:create(staticOverFun)}))
		end
	end


----------------------------------------------------------------------------------------------------------
	--禁用幻兽技能操作
	function layer:setDisabled( falg )
		skillImage:setEnable( not falg )	
	end
	
	return layer
end

return M
