--[[

		轮次数展示

]]--
local M = {}

local logic = requires(IMG_PATH , "GameLuaScript/Scene/battle/logicLayer" )
local petLayer = requires(IMG_PATH , "GameLuaScript/Scene/battle/pet/petLayer" )
local PATH = IMG_PATH .. "image/scene/battle/"
function M:run( type , data )
	logic:pause( "trun" )
	local isFirstClear = true

	
	local bg = display.newSprite(PATH .. "turn/turn_bg.png")
	bg:setOpacity(0)
	setAnchPos(bg , display.cx , display.cy , 0.5 , 0.5)
	logic:getLayer("effect"):addChild( bg )
	
	local wheelNum = display.newSprite( PATH .. "turn/turn" .. data.turn .. ".png")
	setAnchPos(wheelNum , display.cx , display.cy , 0.5 , 0.5)
	bg:setOpacity(0)
	logic:getLayer("effect"):addChild( wheelNum )
	
	local actionTime = 0.2
	local actions = CCArray:create()
	actions:addObject( CCMoveTo:create( actionTime , ccp(display.cx , display.cy)))
	actions:addObject( CCFadeIn:create( actionTime ))
	bg:runAction( CCSequence:create( actions ) )
	
	
	local function markAction(params)
		local group = params.group
		local curMarkData = DATA_Battle:get("report")["prepare"]["p" .. group .. "_natural"]
		
		if tonumber( curMarkData ) ~= 0 then
			audio.playSound(IMG_PATH .. "sound/atk_skill.mp3")
			--执行动画效果
			local effSprite
			local effFrames = display.newFramesWithImage( IMG_PATH.."image/scene/battle/pet/markup_eff.png" , 4 )
			effSprite =display.playFrames( 0  , 0  , 
											effFrames ,
											 0.2 ,
											  { 
											  	delay = 0.01,
											  	onComplete =
												 function() 
													effSprite:removeFromParentAndCleanup( true ) 
												 end
												 } )
			setAnchPos( effSprite , display.cx  , group == 1 and 255 or 580 , 0.5 , 0.5 )
			logic:getLayer("effect"):addChild( effSprite )
			
			local merge = display.newSprite( IMG_PATH.."image/scene/battle/markup_text.png" )
			setAnchPos( merge , display.cx , group == 1 and 230 or 560 , 0.5 , 0 )
			logic:getLayer("effect"):addChild( merge )
			
			--[[特效开始]]
			merge:setScale(0.1)
			transition.scaleTo(merge, {
				time = 0.2,
				scale = 2.5,
			})
			transition.scaleTo(merge, {
				delay = 0.2,
				time = 0.2,
				scale = 1,
			})
			
			transition.moveTo(merge, { 
				delay = 0.6 , 
				time = 0.4, 
				x = display.cx ,
				y = group == 1 and 230 or 560 ,
				onComplete = function()
					merge:removeFromParentAndCleanup(true)	-- 清除自己
					
					
					local handler
					local function delayRealize()
						CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handler)
						handler = nil
						if params.onComplete then params.onComplete() end
					end
					handler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(delayRealize , 1 , false)
					
				end})
				
				
		else
			if params.onComplete then params.onComplete() end
		end
	end
	
	local function overHandler()
			logic:resume( "trun" )
			logic:resume( )
	end
	--展示加成
	local function showMarkup()
		markAction({group = 1 , onComplete = 
								function() 
									markAction({group = 2 , onComplete = overHandler })
								end})
	end
	
	
	
	local function clear()
		if not isFirstClear then
			return
		end
		isFirstClear = true
		
		if bg then
			transition.fadeTo( bg , { opacity = 0 , time = 0.2 ,
			onComplete = 
			function()
				bg:removeFromParentAndCleanup( true )
				bg = nil
			end})
		end

		if wheelNum then
			transition.fadeTo( wheelNum , { opacity = 0 , time = 0.2 ,
			onComplete = 
			function()
				wheelNum:removeFromParentAndCleanup( true )
				wheelNum = nil
				if data.turn == 1 then
					showMarkup()
				else
					overHandler()
				end
			end})
		end
	end
	--展示双方敏捷值
	local function showAgile()
		local agileData = logic:getAgile()
		
		--自己一方初始值
		local selfAgileSp = display.newSprite( PATH .. "agile_value.png" )
		setAnchPos( selfAgileSp , -50 , 383 , 0 , 0.5 )
		logic:getLayer("effect"):addChild( selfAgileSp )
		
		--敌方敏捷初始值
		local foeAgileSp = display.newSprite( PATH .. "agile_value.png" )
		setAnchPos( foeAgileSp , -50 , 478 , 0 , 0.5 )
		logic:getLayer("effect"):addChild( foeAgileSp )
		
		
		
		local selfFalg = false
		local foeFalg = false
		local little = agileData.self > agileData.foe and agileData.foe or agileData.self
		local cut = math.round( ( little / 10 ) )
		local function refreshNum( _target , num  , group )
			num = num + cut
			cut = cut + 5
			
			if group == 1 then
				if num >= agileData.self then
					selfFalg = true
					num = agileData.self
				end
			else
				if num >= agileData.foe then
					foeFalg = true
					num = agileData.foe
				end
			end
			
			local target = _target
			if target then target:removeFromParentAndCleanup( true ) end
			
			
			target = getImageNum( num , COMMONPATH .. "bnNum.png" , group )
			setAnchPos( target , 120 , 15 , 0 , 0.5 )	
			if group == 1 then
				selfAgileSp:addChild( target )
			else
				foeAgileSp:addChild( target )
			end
			

			
			
			
			if selfFalg and  foeFalg then
				local function clearSp()
					if selfAgileSp then
						selfAgileSp:removeFromParentAndCleanup( true )
						selfAgileSp = nil
					end
					
					if foeAgileSp then
						foeAgileSp:removeFromParentAndCleanup( true )
						foeAgileSp = nil
					end
				end
				
				local firstSp = display.newSprite( PATH .. "first.png")
				firstSp:setScale(0.2)
				setAnchPos( firstSp , display.cx , agileData.self >= agileData.foe and 383 or 478 , 0.5 , 0.5 )
				logic:getLayer("effect"):addChild( firstSp )
				
				
				local function firstShow()
					local scaleAction = CCArray:create()
					scaleAction:addObject( CCScaleTo:create( 0.2 , 1.3))
					scaleAction:addObject( CCScaleTo:create( 0.2 , 1))
					scaleAction:addObject( CCDelayTime:create( 1.5 ) )
					scaleAction:addObject( CCFadeTo:create( 0.3 , 0 ) )
					scaleAction:addObject( CCCallFunc:create( function() 
											firstSp:removeFromParentAndCleanup(true) 
											firstSp = nil 
											clear()
										end ) )
					firstSp:runAction( CCSequence:create( scaleAction ) )
				end
				
				local delayAction = CCArray:create()
				delayAction:addObject( CCCallFunc:create( firstShow ))
				delayAction:addObject( CCDelayTime:create( 1.5 ) )
				delayAction:addObject( CCCallFunc:create( clearSp ))
				
				logic:getLayer("effect"):runAction(CCSequence:create( delayAction ))
				return
			end
			
			
			
			local function delayFun()
				refreshNum( target , num  , group )
			end
			local handler
			local function delayRealize()
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handler)
				handler = nil
				delayFun()
			end
			handler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(delayRealize , 0.0001 , false)
		end
		
		transition.moveTo(selfAgileSp , {time = 0.2 , x = 12 , easing = "ELASTICOUT"  })
		transition.moveTo(foeAgileSp  , {time = 0.2 , x = 12 , easing = "ELASTICOUT" , onComplete = 
																function()
																	refreshNum( nil , 0 , 1 )
																	refreshNum( nil , 0 , 2 )
																end })
	end
	
	
	
	local actionTime = 0.2
	wheelNum:setScale(0.1)
	local actions2 = CCArray:create()
	local moveAction = CCScaleTo:create( actionTime , 1 )
	actions2:addObject( CCFadeIn:create( actionTime ))
	actions2:addObject( CCEaseBounceOut:create( moveAction ))
	actions2:addObject( CCDelayTime:create( 0.8 ) )
	
	if data.turn ~= 1 then
		actions2:addObject( CCCallFunc:create( clear ) )
	else
		actions2:addObject( CCCallFunc:create( showAgile ) )
	end
	
	wheelNum:runAction( CCSequence:create( actions2 ) )
	


--
--	local function clear()
--		logic:resume( "trun" )
--		logic:resume( )
--		bg:removeFromParentAndCleanup( true)
--		wheelNum:removeFromParentAndCleanup( true)
--	end
--	local handler
--	local function delayRealize()
--		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handler)
--		handler = nil
--		--宠物加攻防展示
--		if data.turn == 1 and petLayer:getPetData( 1 ) then
--			petLayer:showMarkup( { overHandler = clear } )
--		else
--		 	clear()
--		end
--	end
--	handler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(delayRealize , 0.6 , false)

end

return M