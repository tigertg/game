--[[

	死亡后 划动 效果

]]


local M = {}

local logic = requires(IMG_PATH , "GameLuaScript/Scene/battle/logicLayer")
local heroCell = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroCell")
local totalRowNum = 0	--划动总次数

local bgLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/bgLayer")
local skipLayer = requires(IMG_PATH , "GameLuaScript/Scene/battle/skipLayer")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")

local rateValue = 2

--[[执行特效 死亡划动掉宝]]--
function M:run( hero , param )
	param = param or {}
	--清除战斗中英雄卡牌
	if param.clear ~= nil then param.clear() end
	
	local rowNum = 0	--单次鼠标事件      划动次数记录
	totalRowNum = 0	--清除累加次数
	local mask			
	local isSelfDo = false
	local moveAction
	
	local rowIcon
	local rowNumSp		--划动次数
	local countDownTime = 3	--倒计时时间
	local countDonSp	--倒计时
	local layer = display.newLayer()
	local isMax = true
----------------------------------------------------------------------------------------------------------------------
--
--	创建临时英雄卡牌
--
--
	local function createTempHero()

		local tempData = clone( hero:getData() )
		tempData._group = "temp"

		return heroCell.new( tempData )
	end

	--临时英雄卡牌
	local tempHero = createTempHero()
	if param.cur >= param.max then
		logic:pause( "slide" )
		KNMsg:getInstance():flashShow("大侠饶命，今天已经切够50次了！")
		local handle
		local function resumeGame()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
			handle = nil
			logic:resume( "slide" )
		end
		handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(resumeGame , 1 , false)
		isMax = false
		return 
	end

	local function refreshRowNum()
		if rowNumSp then
			rowNumSp:removeFromParentAndCleanup(true)
			rowNumSp = nil
		end
		rowNumSp = getImageNum( rowNum + totalRowNum  , IMG_PATH .. "image/scene/battle/fruit/win/row/num.png" , { decimals = true })
		setAnchPos( rowNumSp , display.cx , 720 , 0.5 , 0.5 )
		layer:addChild( rowNumSp )
	end
----------------------------------------------------------------------------------------------------------------------
--
--	游戏暂停控制
--			
	local function gameStopControl()
		--滑动卡牌时，禁止拖动 跳过按钮 
		skipLayer:setIsDisabled( true )
		logic:pause( "slide" )
		local cutTime = 0
		local function refreshTime()
			if countDonSp then
				countDonSp:removeFromParentAndCleanup(true)
				countDonSp = nil
			else
				local countDownTimeText = display.newSprite(IMG_PATH .. "image/scene/battle/count_down_text.png")
				setAnchPos( countDownTimeText , 23 , display.height - 40 , 0 , 0.5 )
				layer:addChild( countDownTimeText )
			end
			countDonSp = getImageNum( countDownTime - cutTime  , IMG_PATH .. "image/scene/battle/fruit/win/row/num.png" , { decimals = true })
			setAnchPos( countDonSp , 338  , display.height - 40 , 0 , 0.5 )
			layer:addChild( countDonSp )
			cutTime = cutTime + 1
		end
		
		if not Clock:getKeyIsExist( "slide" ) then
			Clock:addTimeFun( "slide" , refreshTime )
		end
		 
		local handle
		--静止时间结束调用函数
		local function timeHandler()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
			handle = nil
			
			Clock:removeTimeFun( "slide" )
			
			--解决跳过报错
			if bgLayer:getIsSkip() then
				bgLayer:setIsSkip( false )
				return true
			end
			
			--累加卡牌消失时未来得累加的单次划动数据
			totalRowNum = totalRowNum + rowNum
			print("总划次数为:"..totalRowNum)
--			totalRowNum = totalRowNum > #param.cleanup_award and #param.cleanup_award or totalRowNum
			logic:bossRowNum( totalRowNum )--划动boss次数
			
			--清除临时英雄
			heroCell:clear( tempHero:getData()["_group"] , tempHero:getData()["_index"] )
			if mask then mask:remove() end
			logic:resume( "slide" )--恢复战斗
			
			
			--滑动卡牌时，禁止拖动 跳过按钮 
			skipLayer:setIsDisabled( false )
		end
		handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(timeHandler , countDownTime , false)
	end
	gameStopControl()
----------------------------------------------------------------------------------------------------------------------
--
--	划动事件处理
--
	tempHero:setPosition( hero.x , hero.y )
	tempHero:setAnchorPoint( ccp( 0.5 , 0.5 ) )
	local scaleRatio = 1.5	--卡牌放大比率
	local heroSize = tempHero:getContentSize()
	
	local tempMaskWidth = heroSize.width * tempHero:getScaleX()
	local rect = CCRectMake(display.cx - heroSize.width * scaleRatio / 2 , display.cy - heroSize.height * scaleRatio / 2 + 100 , heroSize.width * scaleRatio , heroSize.height * scaleRatio )


	--开始点击
	local beginSlide = false
	local firstPoint
	local movePoint
	local beginAngle = nil
	local slided = 0
	
	local function onTouch(eventType , x , y)
		local function countFun( _angleValue )
			rowNum = rowNum + 1
			refreshRowNum()	
			
			begenPoint = x	--更新起始点
			
			--限制光效区域
			local heroSize = tempHero:getPositionAndSize()
			local x = ( x > ( heroSize._x + heroSize._width ) ) and ( heroSize._x + heroSize._width ) or x
			x = ( x < ( heroSize._x ) ) and heroSize._x or x
			local y = ( y > ( heroSize._y + heroSize._height ) ) and ( heroSize._y + heroSize._height ) or y
			y = ( y < ( heroSize._y ) ) and heroSize._y or y
			
			
			local gap = heroSize._width / 2
			local dropCidData = param.cleanup_award[rowNum] or param.cleanup_award[1]
			local propSp = display.newSprite( getImageByType( dropCidData.c ) )
			setAnchPos( propSp , display.cx + ( math.random(1,3)>2 and -gap or gap ) , display.cy , 0.5 , 0.5)
			logic:getLayer("effect"):addChild( propSp )
			
			--人物抖动
			transition.shake(tempHero , { initScale = scaleRatio , addScale = 0.3})
			--掉落 
			transition.moveTo( propSp ,{ time= 1 , x = 150 , y = 10 })
			transition.scaleTo( propSp ,{ time= 1 , scale = 0.5 ,onComplete =
																	function()
																		propSp:removeFromParentAndCleanup( true )
																	end })
																	
    		local knifeShade = display.newSprite(IMG_PATH.."image/scene/battle/knife_shade.png")
    		setAnchPos( knifeShade , x  , y  , 0.5 , 0.5 )
    		logic:getLayer("effect"):addChild( knifeShade )
    		knifeShade:setRotation( 360 - _angleValue)
    		transition.moveTo( knifeShade , { delay = 0.05 , time = 0.1 , onComplete = function() knifeShade:removeFromParentAndCleanup(true) end})		
    		
    		
    		local knife = display.newSprite(IMG_PATH.."image/scene/battle/knife.png")
    		setAnchPos( knife , x , y , 0.5 , 0.5 )
    		logic:getLayer("effect"):addChild( knife )
    		knife:setRotation( 360 - _angleValue)
    		transition.moveTo( knife , {time = 0.1 , onComplete = function() knife:removeFromParentAndCleanup(true) end})		
    	end
    	
    	
		if not isSelfDo then
			isSelfDo = true
			transition.removeAction( moveAction )
			rowIcon:removeFromParentAndCleanup(true)
		end
		
		if eventType == CCTOUCHBEGAN then
			-- 判断是否点中了这张卡牌
	    	if rect:containsPoint( ccp(x , y) ) then
	    		firstPoint = { x = x , y = y}
	    		movePoint = { x = x , y = y}
	    		beginSlide = true
	    		beginAngle = nil
	    		slided = 0
	    	else
	    		beginSlide = false
    		end
    		return true
		elseif eventType == CCTOUCHMOVED then
			if not beginSlide then
				if rect:containsPoint( ccp(x , y) ) then
	    			firstPoint = { x = x , y = y}
	    			movePoint = { x = x , y = y}
	    			beginSlide = true
	    			beginAngle = nil
	    			slided = 0
    			end
    			
    			return false
			end
			
			local distance = math.sqrt( (x - movePoint.x) * (x - movePoint.x) + (y - movePoint.y) * (y - movePoint.y) )
			if distance > 2 then
				local angle = math.deg( math.acos( (x - movePoint.x) / distance ) )
				if y - movePoint.y < 0 then
					angle = 360 - angle
				end
				movePoint = { x = x , y = y}
				
				if beginAngle == nil then
					beginAngle = angle
				else
					local max = 90
					local diff = angle - beginAngle
					if math.abs( diff ) <= max then
						-- 方向没有变
						slided = slided + 1
					else
						diff = angle - (beginAngle + 360)
						if math.abs( diff ) <= max then
							-- 方向没有变
							slided = slided + 1
						else
							beginSlide = false
							slided = 0
						end
					end
				end
				
				if slided == 2 then
					countFun(beginAngle)
				end			
			end
			
		elseif eventType == CCTOUCHENDED then
			beginSlide = false
		end

	    return true
	end

--------------------------------------------------------------------------
	layer:setTouchEnabled( isMax )
	layer:registerScriptTouchHandler(onTouch , false , -140 , true)
	
	layer:addChild( tempHero )
	

	local function tipAction()
		local tipText = display.strokeLabel( "请左右划牌来切开牌" , display.cx - 240  , display.cy - 50 , 18 , ccc3(0xdb , 0x25 , 0x21) , nil , nil ,
				 {
				 	 dimensions_width = 480 , 
				 	 dimensions_height = 30 , 
				 	 align = 1 
				 })
		layer:addChild( tipText )
		
		local distance = heroSize.width / 2 + 50  	--左右移动范围
		rowIcon = display.newSprite( IMG_PATH.."image/scene/battle/hand.png" )
		setAnchPos( rowIcon , display.cx - distance  , display.cy + heroSize.height / 100  , 0.2  , 0.5)
		layer:addChild( rowIcon )
		
		local isTow = false
		local function rowHandAction()
			isTow = not isTow
			moveAction = transition.moveTo( rowIcon ,{ time = 1 , x = display.cx + ( isTow and distance or -distance ) , onComplete = rowHandAction })
		end
		rowHandAction()
	end
	tipAction()
	--英雄卡牌动画
	transition.moveTo( tempHero , { time = 1 , x = display.cx - heroSize.width / 2  , y = display.cy - heroSize.height / 2 + 100, easing = "ELASTICINOUT" } )
	transition.scaleTo( tempHero , {time = 1 , scale = scaleRatio ,easing = "ELASTICINOUT" , onComplete = 
				function()
					local numBg = display.newSprite(IMG_PATH .. "image/scene/battle/fruit/win/row/row_num_bg.png")
					setAnchPos( numBg , display.cx , 720 , 0.5 , 0.5)
					layer:addChild( numBg )
					refreshRowNum()
				end	} )
--	transition.playSprites( tempHero , "tintTo" , {
--     		time = 1,
--     		r = 200,
--     		g = 0 ,
--     		b = 0
--     	})
	
	mask = KNMask:new( { item = layer , opacity = 180 } )
	logic:getLayer("effect"):addChild( mask:getLayer() )
	return true
end


return M