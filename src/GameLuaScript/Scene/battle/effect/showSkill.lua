--[[

	武将技能特写

]]


local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local PATH = IMG_PATH .. "image/scene/battle/heroSkill/"
--[[执行特效]]
function M:run( atk_hero , be_atk_hero ,param )
	if type(param) ~= "table" then param = {} end
	logic:pause( "showSkill" )
--	if param.callBack then  
--		param.callBack( { overHandler = function() logic:resume( "showSkill" )	end })
--		return 
--	end
	--判断攻击方属于哪一组
	local isSelf = tonumber( atk_hero:getData()._group ) == 1 
	
	local function twoEff()
		local skillName
		local function thrEff()
			--背景圆盘
			local trayBg = display.newSprite( PATH .. "tray.png" )
			setAnchPos( trayBg , display.cx ,isSelf and 0 or 350 , 0.5 )
			logic:getLayer("skillAction"):addChild(trayBg)
			transition.fadeIn(trayBg , { time = 0.3 , delay = 0.3 } )
			
			local bigHead
			local function playLight()
			
				local heroLayer = logic:getLayer( isSelf and "enemyHero" or "selfHero")  
				heroLayer:setVisible( true )
				setAnchPos( heroLayer , 0 , isSelf and 100 or -100 )
				
				--光效
				local sprite
				local frames = display.newFramesWithImage(PATH .. "light.png" , 6 )
				sprite = display.playFrames(
					display.cx, 
					isSelf and 280 or 630,
					frames,
					0.1,
					{
						delay = 0.05,
						onComplete = function()
							sprite:removeFromParentAndCleanup(true)	-- 清除自己
							--回调攻击效果
							if param.callBack then
								param.callBack( { overHandler = function()
																	logic:resume( "showSkill" )
																	bigHead:removeFromParentAndCleanup(true)
																	skillName:removeFromParentAndCleanup(true)
																	trayBg:removeFromParentAndCleanup(true)
																	setAnchPos( heroLayer , 0 , 0 )
																end , 
													offset ={ targetLayer = isSelf and "enemyHero" or "selfHero" , valueY = isSelf and 100 or -100 }
																})
							end
						end
					}
				)
				-- 添加到 特效层
				logic:getLayer("skillAction"):addChild( sprite )
			end
			
			
			local function createImage()
				local tempLayer = display.newLayer()
				
					local light = display.newSprite( IMG_PATH.."image/scene/home/card_light.png" )
					setAnchPos( light, 0 ,0 , 0.5 , 0.5 )
					tempLayer:addChild( light )
					
					local function createAction()
						local action
						local array = CCArray:create()
						array:addObject(CCScaleTo:create(1,0.9))
						array:addObject(CCScaleTo:create(1,0.98))
						array:addObject(CCCallFunc:create(
						function()
							light:runAction(createAction())
						end))
						action = CCSequence:create(array)
						return action
					end
					light:runAction(createAction())
					
					local isNpc = atk_hero:getData().npc_id ~= nil 
					local curCid = atk_hero:getData().cid or atk_hero:getData().npc_id 
					local cidType = getCidType( curCid )					
					
					local bg = display.newSprite( IMG_PATH.."image/scene/home/card_bg.png" ) 
					setAnchPos( bg , 0 , 0 , 0.5 , 0.5 )
					tempLayer:addChild( bg )
					
					if getConfig( cidType , curCid  , "special" ) == 1 then
						local tempSp = display.newSprite( IMG_PATH.."image/scene/home/special_frame.png" )
						setAnchPos( tempSp , 0 , 20 , 0.5 , 0.5 )
						tempLayer:addChild( tempSp )
					end
					
					local bgSize = bg:getContentSize()
					
					local roleImage = display.newSprite( getImageByType( curCid , "b") )
					setAnchPos( roleImage ,  0 + 6 , 0 + 10  , 0.5 , 0.5 )
					tempLayer:addChild( roleImage )
					
					
					local star = getConfig( cidType , curCid , "star" )
					--获取NPC星级					
					if isNpc then
						local tempCid = getConfig( cidType , curCid , "gid" )
						star = getConfig( getCidType( tempCid ) , tempCid , "star" ) 
					end
					
					local bottom = display.newSprite(IMG_PATH.."image/scene/home/card_bottom_" .. star .. ".png")
					setAnchPos(bottom , -2 ,  - 2 - bgSize.height / 2 , 0.5 )
					tempLayer:addChild(bottom)
					
					bottom = display.strokeLabel( getConfig( cidType , curCid ,"name" ) , 135 , 5 , 25 )
					setAnchPos(bottom , 0 , 5 - bgSize.height / 2 , 0.5)
					tempLayer:addChild(bottom)
					
					for i = 1, star do
						bottom = display.newSprite(IMG_PATH.."image/scene/home/star.png")
						setAnchPos(bottom , ( i - 1 ) * bottom:getContentSize().width  - (bottom:getContentSize().width * star) / 2  ,36 - bgSize.height / 2 )
						tempLayer:addChild(bottom)
					end
					

					tempLayer:setContentSize( bgSize )
				return tempLayer
			end
			--生成人物图像
			bigHead =createImage()
			setAnchPos( bigHead ,  display.cx , isSelf and 230 or 580  , 0 , 0 )
			logic:getLayer("skillAction"):addChild(bigHead)
			bigHead:setScale( 0.1 )
			transition.scaleTo( bigHead , { scale = 1 , time = 0.5 , easing = "ELASTICOUT" , onComplete = playLight } )
			
		end
		
		--技能名字
		skillName = display.newSprite( IMG_PATH .. "image/scene/battle/skillAction/ptext_" .. param.skillID .. ".png" )
		setAnchPos( skillName , 400 , display.cy - ( isSelf and 80 or -250 ), 0.5 , 0.5 )
		logic:getLayer("skillAction"):addChild(skillName)
		
		
		skillName:setScale(0.2)
		local t = 0.3
		local actions = CCArray:create()
		actions:addObject( CCDelayTime:create( 0.1 ) )
		local fuseAry = CCArray:create()
		fuseAry:addObject( CCCallFunc:create( thrEff ) )
		fuseAry:addObject( CCEaseBounceOut:create( CCScaleTo:create( t , 1 ) ) )
		actions:addObject(CCSpawn:create( fuseAry ) )
		skillName:runAction( CCSequence:create( actions ) )
	end
	
	
	
	
	--隐藏战斗所有层
	logic:skillHide( false )
	--生成背景光
	local bgLight = display.newSprite( PATH .. "bg_light.png" )
	bgLight:setScaleX(53)
	setAnchPos( bgLight , 0 , display.cy , 0 , 0.5)
	logic:getLayer("skillAction"):addChild(bgLight)
	
	--光线
	for i = 1 ,  math.random( 2 , 4 ) do
		local line = display.newSprite( COMMONPATH .. "line.png" )
		local randomNumY  = math.random( 1 , 2 ) ~= 1 and -math.random( 1 , 132 ) or math.random( 1 , 132 )
		local randomAddX , targetX
		if math.random( 1 , 2 ) == 2 then
			randomAddX , targetX = math.random( 0 , 200  ) , math.random( 600 , 800 )
		else
			randomAddX , targetX = math.random( 600 , 800) , math.random( -200 , 0 )
		end
		setAnchPos( line ,randomAddX , display.cy + randomNumY , 0.5 , 0.5)
		logic:getLayer("skillAction"):addChild( line )
		transition.moveTo( line , {
									time = 1 ,
									x = targetX , 
									onComplete = function ()
										line:removeFromParentAndCleanup(true)
									end})
											
	end
	
	
	
	--生成人物图像
	local bigHead = display.newSprite( getImageByType( atk_hero:getData().cid or atk_hero:getData().npc_id , "b") )
	setAnchPos( bigHead , 70 , display.cy , 0.5 , 0.5)
	logic:getLayer("skillAction"):addChild(bigHead)
	
	
	local maskT = display.newSprite( PATH .. "bg_light.png" )
	maskT:setScaleX(53)
	transition.tintTo(maskT , { r = 0 , g = 0 , b = 0 , time = 0 })
	setAnchPos( maskT , 0 , display.cy + 270, 0 , 0.5)
	logic:getLayer("skillAction"):addChild(maskT)
	
	local maskB = display.newSprite( PATH .. "bg_light.png" )
	maskB:setScaleX(53)
	transition.tintTo(maskB , { r = 0 , g = 0 , b = 0 , time = 0 })
	setAnchPos( maskB , 0 , display.cy - 270 , 0 , 0.5)
	logic:getLayer("skillAction"):addChild(maskB)
	
	local function clearSelf()
		local t = 0.6
		transition.moveTo( maskT , { y = display.cy - 132, time = t } )
		transition.moveTo( maskB , { 
									 y = display.cy + 132,
									 time = t,
									 onComplete = function()
									 			maskT:removeFromParentAndCleanup(true)
												maskB:removeFromParentAndCleanup(true)
												
												bgLight:removeFromParentAndCleanup(true)
												bigHead:removeFromParentAndCleanup(true)
												twoEff()
									 end
									 })
	end
	bigHead:setScaleX(1.2)
	local t = 1
	local actions = CCArray:create()
	actions:addObject( CCMoveTo:create( 0.3 , ccp( display.cx + 100 , display.cy ) ) )
	actions:addObject( CCCallFunc:create( function()bgLight:setVisible(false)end )  )
	actions:addObject( CCDelayTime:create( 0.1 )  )
	actions:addObject( CCCallFunc:create( function()bgLight:setVisible(true)end )  )
	actions:addObject( CCDelayTime:create( 0.1 )  )
	actions:addObject( CCCallFunc:create( function()bgLight:setVisible(false)end )  )
	actions:addObject( CCDelayTime:create( 0.1 )  )
	actions:addObject( CCCallFunc:create( function()bgLight:setVisible(true)end )  )
	actions:addObject( CCDelayTime:create( 0.5 )  )
	actions:addObject( CCCallFunc:create( clearSelf ) )
	bigHead:runAction( CCSequence:create( actions ) )
	



	return true
end

return M