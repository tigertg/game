--[[

		释放宠物技能 展现

]]--
local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local petLayer = requires(IMG_PATH , "GameLuaScript/Scene/battle/pet/petLayer")
local PATH = IMG_PATH .. "image/scene/battle/heroSkill/"
local backHeroCell = requires( IMG_PATH,"GameLuaScript/Scene/battle/backHeroCell")
local heroLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroLayer")
function M:run( type , data )
	logic:pause( "skillpet" )
	
	local function overHandler()
		logic:resume( "skillpet" )
		logic:resume( )
	end
	--更新自己一方宠物活力值
	if data.p1_power then
		petLayer:getPetData(1).power = data.p1_power
	end
	
--	success 成功		loyal 忠诚不足
	if data.result == "loyal" then
		KNMsg:getInstance():flashShow("幻兽忠诚度不足,技能释放失败！")
		overHandler()
		return
	end
	
	--如果没有 释放技能 则直接返回
	if data.type == "clear" then
		data.status = data.target
	else
		if data.status and ( #data.status == 0 ) then overHandler() end
	end
	
	local isSelf = tonumber( data.group) == 1 and true or false
	--刷新技能sp
	petLayer:selfRefreshPetSp( data.p1_sp , 1 )
	petLayer:selfRefreshPetSp( data.p2_sp , 2 )
	
	
	--存在的技能
	local existEff = {	["chaos"]   = 5 ,		--混乱
						["clear"]   = 5 ,		--清除
						["poison"]  = 5 ,		--放毒
						["recover"] = 5 ,		--恢复
						["silence"] = 5 ,		--沉默
						["sleep"]   = 5 ,		--沉睡
						["stone"]   = 4 ,		--石化
						["还差复活"]   = "relive" 	--复活
						}
						
	--存在的标记
	local existFlag = {	["chaos"]   = "chaos" ,		--混乱
						["poison"]  = "poison" ,	--放毒
						["silence"] = "silence" ,	--沉默
						["sleep"]   = "sleep" ,		--沉睡
						["stone"]   = "stone" ,		--石化
						}
	local function showText( hero )
		--[[文字特效]]
			local group = display.newSprite(IMG_PATH.."image/scene/battle/effect/" .. data.type .. "_text.png")
			display.align(group , display.CENTER , hero._cx , hero._cy )
			
			transition.moveTo(group, {
				time = 0.3,
				y = hero._y + hero._height + 20,
			})
			group:setScale(0.3)
			transition.scaleTo(group, {
				time = 0.2,
				scale = 1.5,
			})
			transition.scaleTo(group, {
				delay = 0.2,
				time = 0.2,
				scale = 1,
			})
			
			
			transition.fadeOut(group, {
				delay = 0.3,
				time = 0.9,
				onComplete = function()
					group:removeFromParentAndCleanup(true)	-- 清除自己
				end
			})
			
			-- 添加到 特效层
			logic:getLayer("effect"):addChild( group )
	end
						
						
	local effectTime = 0.15	
	local function renderEffect( tempData )
		
		--目标英雄
		local targetHero = requires( IMG_PATH,"GameLuaScript/Scene/battle/heroCell"):get( tempData.group , tempData.index )
		local targetSizeInfo = targetHero:getPositionAndSize()
		
		
		
		--添加状态图片
		local function lockEffect()
			
			--给目标英英雄添加 效果数据
			local  flagSp = display.newSprite(IMG_PATH.."image/scene/battle/pet/eff_flag/"..data.type.."_flag.png")
			--英雄状态记录
			targetHero:setData( data.type , { keep = tempData.keep , flag = flagSp })
			
			local lockSpSize = flagSp:getContentSize()
			setAnchPos( flagSp , lockSpSize.width / 2 - 5, lockSpSize.height / 2 , 0.5 , 0.5 )
			targetHero:addChild(flagSp)
			
			local actionTime = 0.2
			local actions = CCArray:create()
			actions:addObject( CCFadeIn:create( actionTime ))
			actions:addObject( CCCallFunc:create( overHandler) )
			flagSp:runAction( CCSequence:create( actions ) )

		end
		
		--粒子效果
		local path = IMG_PATH.."image/common/particle.plist"
		if  io.exists(path) then
	    else
	        local array = string.split(path, "/")
	        local str = ""
	        for i = 5 ,table.getn(array) do
	            if i == table.getn(array) then
	               str = str ..array[i]
	            else
	       	       str = str ..array[i].."/"
	             end
	        end
	         path = str
	    end
	    local addPoint = tonumber( data.group ) == 2  and { x = 400 , y = 700 } or { x = 80 , y = 150 }
		local releaseGrain = CCParticleSystemQuad:create(path)
		releaseGrain:setPosition( addPoint.x , addPoint.y )
		logic:getLayer("pet"):addChild( releaseGrain )
		
		transition.moveTo(releaseGrain, {
			time = effectTime * 3, 
			x = targetSizeInfo._cx , 
			y = targetSizeInfo._cy ,
			onComplete = function()
				releaseGrain:removeFromParentAndCleanup( true )
				
				--效果图片存在的话
				if existEff[ data.type ] then
					--效果动画
					local sprite
					local frames = display.newFramesWithImage(IMG_PATH.."image/scene/battle/pet/eff_flag/eff_"..data.type..".png" , tonumber( existEff[ data.type ] ) )
					sprite = display.playFrames(
						targetHero._cx, 
						targetHero._cy,
						frames,
						0.15,
						{
							delay = 0.05,
							onComplete = function()
								sprite:removeFromParentAndCleanup(true)	-- 清除自己
								
								showText( targetHero )
								
								--改变锁定状态
								if existFlag[data.type]  then
									lockEffect()
								else
									if data.type == "clear" then
										for key , v in pairs(existFlag) do
										 	local targetHeroData = targetHero:getData()[key..""]
										 	if targetHeroData then
												targetHeroData["new"..key] = 0
												targetHeroData.flag:removeFromParentAndCleanup( true )
												targetHeroData = nil
												targetHero:setData( key.."" , nil )
										 	end
						
										end
									end
									
									overHandler()
								end
								
							end
						}
					)
					sprite:setAnchorPoint( ccp(0.5 , 0.5) )
					-- 添加到 特效层
					
					logic:getLayer("effect"):addChild( sprite )
				end
				
			end
		} )
		
		
		
	end
	
	
	



---------------------------------------------入场动画
--
--	--生成背景光
	local petEffBg = display.newSprite( IMG_PATH .. "image/scene/battle/pet/" .. "pet_eff_bg.png" )
	petEffBg:setScaleX(53)
	setAnchPos( petEffBg , 0 , isSelf and 0 or display.top , 0 , isSelf and 0 or 1)
	logic:getLayer("skillAction"):addChild(petEffBg)
	transition.tintTo(petEffBg , { r = 0 , g = 0 , b = 0 , time = 0 })
	--
	local bgLight = display.newSprite( IMG_PATH .. "image/scene/battle/pet/" .. "pet_eff_bg.png" )
	bgLight:setScaleX(53)
	setAnchPos( bgLight , 0 , isSelf and 0 or display.top , 0 , isSelf and 0 or 1)
	logic:getLayer("skillAction"):addChild(bgLight)
	
	--光线
	for i = 1 ,  math.random( 2 , 4 ) do
		local line = display.newSprite( COMMONPATH .. "line.png" )
		local randomNumY  = math.random( 1 , 2 ) ~= 1 and - math.random( 1 , 198 ) or math.random( 1 , 198 )
		local randomAddX , targetX
		if math.random( 1 , 2 ) == 2 then
			randomAddX , targetX = math.random( 0 , 200  ) , math.random( 600 , 800 )
		else
			randomAddX , targetX = math.random( 600 , 800) , math.random( -200 , 0 )
		end
		setAnchPos( line ,randomAddX , isSelf and 0 + randomNumY or display.top - randomNumY , 0.5 , isSelf and 0 or 1 )
		
		
		logic:getLayer("skillAction"):addChild( line )
		transition.moveTo( line , {
									time = 1 ,
									x = targetX , 
									onComplete = function ()
										line:removeFromParentAndCleanup(true)
									end})
											
	end
	
	
	
	--生成宠物图像
	local petData = petLayer:getPetData( data.group )
	
	local bigHead = display.newSprite( IMG_PATH .. "image/pet/" .. petData.cid ..  ".png" )
	setAnchPos( bigHead , isSelf and display.width or 0 , isSelf and 0 or display.top , 0 , isSelf and 0 or 1)
	logic:getLayer("skillAction"):addChild(bigHead)
	
	
	
	local function clearSelf()
		petEffBg:removeFromParentAndCleanup(true)
		bgLight:removeFromParentAndCleanup(true)
		bigHead:removeFromParentAndCleanup(true)
		
		audio.playSound(IMG_PATH .. "sound/pet_skill_atk.mp3")
		
		if data.type ~= "relive" then	--复活单独处理
			for key , v in  pairs(data.status) do
				renderEffect( v )
			end
		else
			local function renderEffect( tempData )
				--目标英雄
				local targetHero = requires( IMG_PATH,"GameLuaScript/Scene/battle/backHeroCell"):get( tempData._group , tempData._index )
			 	targetHero:setVisible( false )
				local targetSizeInfo =  targetHero:getPositionAndSize()
				
				--粒子效果
				local path = IMG_PATH.."image/common/particle.plist"
				if  io.exists(path) then
			    else
			        local array = string.split(path, "/")
			        local str = ""
			        for i = 5 ,table.getn(array) do
			            if i == table.getn(array) then
			               str = str ..array[i]
			            else
			       	       str = str ..array[i].."/"
			             end
			        end
			         path = str
			    end
			    
			    local addPoint = tonumber( data.group ) == 2  and { x = 400 , y = 700 } or { x = 80 , y = 150 }
				local releaseGrain = CCParticleSystemQuad:create(path)
				releaseGrain:setPosition( addPoint.x , addPoint.y )
				logic:getLayer("pet"):addChild( releaseGrain )
				
				
				transition.moveTo(releaseGrain, {
					time = effectTime * 3, 
					x = targetSizeInfo._cx , 
					y = targetSizeInfo._cy ,
					onComplete = function()
						releaseGrain:removeFromParentAndCleanup( true )
						
						
						local sprite
						local frames = display.newFramesWithImage(IMG_PATH.."image/scene/battle/pet/eff_flag/eff_recover.png" , 5)
						sprite = display.playFrames(
							targetHero._cx, 
							targetHero._cy,
							frames,
							0.05,
							{
								delay = 0.05,
								onComplete = function()
									sprite:removeFromParentAndCleanup(true)	-- 清除自己
									targetHero:setVisible( true )
									--解除锁定
									if param.onComplete~=nil then param.onComplete() end
								end
							}
						)
						sprite:setAnchorPoint( ccp(0.5 , 0.5) )
						-- 添加到 特效层
						logic:getLayer("effect"):addChild( sprite )
					end
				} )
			end
			--初始化复活组
			backHeroCell:initGroup( data.group )
			local back_hero
			--生成替补武将
			for key , v in pairs(data.p1_back) do
				back_hero = backHeroCell.new( v )
				heroLayer:setBackOneHero(back_hero , back_hero:getData("_group") , back_hero:getData("_index") )
				back_hero:setEnabled( true )
			end
			
			--需要做效果的替补武将
			for key , v in  pairs( data.target ) do
				renderEffect( v )
			end
		end
		
		

	end
	
	--宠物技能释放衬托效果
	local function petSkillEff()
		local petEff
		local tempFremes = display.newFramesWithImage( IMG_PATH.."image/scene/battle/pet/skill_eff.png" , 5 )
		petEff = display.playFrames(
			isSelf and 87 or display.cx + 161 , 
			isSelf and 87 or display.top - 93 ,
			tempFremes , 
			effectTime , 
			{
				onComplete = function()
					petEff:removeFromParentAndCleanup(true)	-- 清除自己
				end
			})
		logic:getLayer("pet"):addChild( petEff )
		
	end
	local t = 1
	audio.playSound(IMG_PATH .. "sound/pet_skill_start.mp3") 
	local actions = CCArray:create()
	actions:addObject( CCMoveTo:create( 0.3 , ccp( isSelf and 20 or display.cx + 78 , isSelf and 25 or display.top - 4 ) ) )
	actions:addObject( CCCallFunc:create( function() bgLight:setVisible(false)end )  )
	actions:addObject( CCDelayTime:create( 0.1 )  )
	actions:addObject( CCCallFunc:create( function()bgLight:setVisible(true)end )  )
	actions:addObject( CCCallFunc:create( petSkillEff ) )
	actions:addObject( CCDelayTime:create( 0.1 )  )
	actions:addObject( CCCallFunc:create( function()bgLight:setVisible(false)end )  )
	actions:addObject( CCDelayTime:create( 0.1 )  )
	actions:addObject( CCCallFunc:create( function()bgLight:setVisible(true)end )  )
	actions:addObject( CCMoveTo:create( 0.05 , ccp( isSelf and 20 or display.cx + 78 , isSelf and 71 or display.top - 50 ) ) )
	actions:addObject( CCMoveTo:create( 0.1 , ccp( isSelf and 20 or display.cx + 78 , isSelf and 25 or display.top - 4 ) ) )
	actions:addObject( CCCallFunc:create( clearSelf ) )
	bigHead:runAction( CCSequence:create( actions ) )

end


return M
