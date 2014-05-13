--[[

		轮次数展示

]]--
local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local petLayer = requires(IMG_PATH , "GameLuaScript/Scene/battle/pet/petLayer")
local PATH = IMG_PATH .. "image/scene/battle/heroSkill/"
local backHeroCell = requires( IMG_PATH,"GameLuaScript/Scene/battle/backHeroCell")
local heroLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroLayer")
local effectLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/effectLayer")
local slideBossData
function M:run( type , data )
	logic:pause( "skillpet" )

	local function overHandler()
		logic:resume( "skillpet" )
		logic:resume( )
		effectLayer:changeActions( data["change"] , data )
	end

	local isSelf = tonumber( data.group) == 1 and true or false
	--刷新技能sp
	petLayer:selfRefreshPetSp( data.p1_sp , 1 )
	petLayer:selfRefreshPetSp( data.p2_sp , 2 )


	--存在的技能
	local existEff = {
		mabi         = 6 ,	 -- 麻痹	雷系
		dongjie      = 6 ,	 -- 冻结	冰系
		hunluan      = 5 ,	 -- 混乱	火系
		zhongdu      = 5 ,   -- 中毒	风系
		huifu        = 5 ,	 -- 恢复	水系
	}
	--存在的标记
	local existFlag = {
		mabi         = "mabi" ,		 -- 麻痹	虚弱
		dongjie      = "dongjie" ,	 -- 冻结	冰冻
		hunluan      = "hunluan" ,	 -- 混乱	破甲
		zhongdu      = "zhongdu" ,   -- 中毒	中毒
	}
	
	--存在的失败标记
	local existLost = {
		dongjie		= "dongjie" ,
		hunluan		= "hunluan" , 
		mabi		= "mabi" ,
		zhongdu		= "zhongdu" ,
	}

	local function showText( hero )
		--[[文字特效]]
		local group = display.newSprite(IMG_PATH.."image/scene/battle/effect/" .. data.type .. "_text.png")
		
		display.align(group , display.CENTER , hero._cx , hero._cy )
		
		if data.type == "mabi" or data.type == "hunluan" then
			if data.type == "mabi" then
				group = display.newSprite( IMG_PATH .. "image/scene/battle/effect/def_text_flag.png")
			elseif data.type == "hunluan" then
				group = display.newSprite( IMG_PATH .. "image/scene/battle/effect/atk_text_flag.png")
			end
			group:addChild( display.newSprite( IMG_PATH ..  "image/scene/battle/effect/reduce_flag.png" , 35 , 0 , 0 , 0 ) )
			local debuff =  getConfig("petskill" , data.cid , data.lv ) 
			debuff = math.floor( debuff.debuff )
			local numText = getImageNum( debuff ,  COMMONPATH .. "hp.png" )
			local numTextWidth = numText:getContentSize().width
			group:addChild( numText )
			setAnchPos( numText , 70 , 0 , 0 , 0 )
			group:addChild( display.newSprite( IMG_PATH ..  "image/scene/battle/effect/per_cent.png" , numTextWidth + 70 + 10 , 0 , 0 , 0 ) )
			display.align(group , display.CENTER , hero._cx - 55 , hero._cy )
		end
		
		
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

--	--刷新血量
--	local function upHp( tempData )
--		--目标英雄
--		local targetHero = requires(IMG_PATH , "GameLuaScript/Scene/battle/heroCell"):get( tempData.group , tempData.index )
--		--中毒减血
--		targetHero:setData("hp" , tempData.hp)
--		targetHero:refreshViewHp()
--
--		--清除挂掉的人
--		local function clear()
--			local heroAction_die = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroAction/die")
--			heroAction_die:normal( targetHero , {
--				onComplete = function()
--					--死亡动画执行完毕
--					local heroCell = requires(IMG_PATH , "GameLuaScript/Scene/battle/heroCell")
--					heroCell:clear( tempData["group"] , tempData["index"] )
--				end
--			})
--		end
--		if tonumber(tempData["hp"]) <= 0 then
--			--划动掉宝 敌方死亡触发
--			local dieCid = targetHero:getData().cid or targetHero:getData().npc_id
--			slideBossData = DATA_Battle:get("report")["prepare"].boss or {}
--			if slideBossData.boss_cid == dieCid then
--				local effect_slide = requires(IMG_PATH,"GameLuaScript/Scene/battle/effect/slide")
--				local curTempData = slideBossData or {}
--				--出现slide证明当前英雄已死亡,需要执行清除
--				curTempData.clear =clear()
--				effect_slide:run2( targetHero ,  curTempData )
--			else
--				clear()
--			end
--		end
--		
--		-- 显示掉血动画
--		local effect_changeHp = requires(IMG_PATH,"GameLuaScript/Scene/battle/effect/changeHp")
--		effect_changeHp:run( targetHero , tempData.hp_diff )
--		
--	end

	local effectTime = 0.15	
	local function renderEffect( tempData , key )
		--目标英雄
		local targetHero = requires( IMG_PATH,"GameLuaScript/Scene/battle/heroCell"):get( tempData.group , tempData.index )
		local targetSizeInfo = targetHero:getPositionAndSize()
		
		--添加状态图片
		local function lockEffect()
			-- 清除上一个状态的图片
			local targetHeroLastEffect = targetHero:getData()["last_effect"]
			if targetHeroLastEffect then
				local targetHeroData = targetHero:getData()[targetHeroLastEffect]
				if targetHeroData and targetHeroData.flag then
					targetHeroData.flag:removeFromParentAndCleanup( true )
					targetHeroData = nil
				end
			end

			-- targetHeroData.flag:removeFromParentAndCleanup( true )
			
			--给目标英英雄添加 效果数据
			local  flagSp = display.newSprite(IMG_PATH.."image/scene/battle/pet/eff_flag/"..data.type.."_flag.png")
			--英雄状态记录
			if data.status then
				targetHero:setData( data.type , { keep = data.status[key].keep , flag = flagSp })
				targetHero:setData( "last_effect" , data.type)
				local lockSpSize = flagSp:getContentSize()
				setAnchPos( flagSp , lockSpSize.width / 2 - 5, lockSpSize.height / 2 , 0.5 , 0.5 )
				targetHero:addChild(flagSp)
			end
			
			local actionTime = 0.2
			local actions = CCArray:create()
			actions:addObject( CCFadeIn:create( actionTime ))
			actions:addObject( CCCallFunc:create( overHandler) )
			flagSp:runAction( CCSequence:create( actions ) )
		end
		
	    local addPoint = tonumber( data.group ) == 2  and { x = 400 , y = 700 } or { x = 80 , y = 150 }
	    
	    
		
	
		local sprite
		local frames = display.newFramesWithImage(IMG_PATH.."image/scene/battle/pet/pet_eff.png" , 3)
		sprite = display.playFrames(
			addPoint.x , addPoint.y ,
			frames,
			0.04,
			{
				forever = true,
			}
		)
		-- 放到 特效层
		sprite:setAnchorPoint( ccp(0.5 , 0.5) )
		logic:getLayer("pet"):addChild( sprite )
		
		for i = 1 , 6 do
			local sprite = display.playFrames(
				addPoint.x , addPoint.y ,
				frames,
				0.04,
				{
					forever = true,
				}
			)
			-- 放到 特效层
			sprite:setAnchorPoint( ccp(0.5 , 0.5) )
			logic:getLayer("pet"):addChild( sprite )
			sprite:setScale( 1 - i * 0.15 )
			transition.moveTo(sprite , { delay = (i * 0.05) ,  time = effectTime * 3 , x = targetSizeInfo._cx , y = targetSizeInfo._cy ,onComplete = function() sprite:removeFromParentAndCleanup(true)end})
--			transition.jumpTo(sprite , { delay = (i * 0.05) ,  time = effectTime * 3 , x = targetSizeInfo._cx , y = targetSizeInfo._cy ,height = 50 , jumps = 1 })
		end
		transition.moveTo(sprite , {
			time = effectTime * 3, 
			x = targetSizeInfo._cx , 
			y = targetSizeInfo._cy ,
			onComplete = function()
				sprite:removeFromParentAndCleanup(true)	-- 清除自己
				
				
				--效果图片存在的话
				local is_debuff = tonumber( data.is_debuff ) == 1 and true or false	--是否添加状态技能flag
				local is_ignore = tonumber( data.is_ignore ) == 1 and true or false --是否盾牌抵挡

				-- 技能是否释放出来，并且没被挡住
				--is_debuff = true
				--is_ignore = true
				if is_debuff and not is_ignore  then
					print('技能释放成功，没被挡住了')
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
									
									if existFlag[ data.type ] then
										showText( targetHero )
									end
									
									--改变锁定状态(必须人还活着)
									if tonumber(tempData["hp"]) > 0 and existFlag[data.type]  then
										lockEffect()
									else
										overHandler()
									end
									
								end
							}
						)
						sprite:setAnchorPoint( ccp(0.5 , 0.5) )
						-- 添加到 特效层
						
						logic:getLayer("effect"):addChild( sprite )
					end


					return
				end

				-- 技能释放出来了，但被挡住了
				if is_debuff and is_ignore  then
					print('技能释放成功，但被挡住了')

					local sprite
					local frames = display.newFramesWithImage(IMG_PATH .. "image/scene/battle/pet/resist.png" , 6 )
					sprite = display.playFrames(
						targetSizeInfo._cx, 
						targetSizeInfo._cy + ( tempData.group == 1 and 70 or -70 ),
						frames,
						0.15,
						{
							onComplete = function()
								sprite:removeFromParentAndCleanup(true)	-- 清除自己
								overHandler()
							end
						}
					)
					sprite:setAnchorPoint( ccp(0.5 , 0.5) )
					logic:getLayer("effect"):addChild( sprite )

					transition.scaleTo( sprite , {time = 0.2 , scale = 1.5 })
					transition.moveTo( sprite , {time = 0.2 , y = targetSizeInfo._cy + ( tempData.group == 1 and 70 or -70 )})
					return
				end


				-- 技能没释放成功
				print('技能没释放成功')
				if existLost[ data.type ] then
					local lostSp = display.newSprite( IMG_PATH .. "image/scene/battle/pet/eff_flag/" .. data.type .. "_lost.png" )
					setAnchPos( lostSp , targetSizeInfo._cx , targetSizeInfo._cy , 0.5 , 0.5 )
					logic:getLayer("effect"):addChild( lostSp )
					lostSp:setScale( 0.1 )
					
					transition.scaleTo( lostSp , { time = 0.2 , scale = 1.5, easing = "ELASTICOUT" ,
					onComplete = function()
						transition.scaleTo( lostSp , { delay = 0.2 , time = 0.2 , scale = 1 , easing = "ELASTICOUT" ,
						onComplete = function()
						lostSp:removeFromParentAndCleanup( true )
						overHandler()
						end})
					end})
				end
				
				
				
				
				
				
			end
		})
	    
	    
	    
--		--粒子效果
--		local path = IMG_PATH.."image/common/particle.plist"
--		if  io.exists(path) then
--	    else
--	        local array = string.split(path, "/")
--	        local str = ""
--	        for i = 5 ,table.getn(array) do
--	            if i == table.getn(array) then
--	               str = str ..array[i]
--	            else
--	       	       str = str ..array[i].."/"
--	             end
--	        end
--	         path = str
--	    end
--		local releaseGrain = CCParticleSystemQuad:create(path)
--		releaseGrain:setPosition( addPoint.x , addPoint.y )
--		logic:getLayer("pet"):addChild( releaseGrain )
--		
--		transition.moveTo(releaseGrain, {
--			time = effectTime * 3, 
--			x = targetSizeInfo._cx , 
--			y = targetSizeInfo._cy ,
--			onComplete = function()
--				releaseGrain:removeFromParentAndCleanup( true )
--
--				
--				--效果图片存在的话
--				local is_debuff = tonumber( data.is_debuff ) == 1 and true or false	--是否添加状态技能flag
--				local is_ignore = tonumber( data.is_ignore ) == 1 and true or false --是否盾牌抵挡
--
--				-- 技能是否释放出来，并且没被挡住
--				--is_debuff = true
--				--is_ignore = true
--				if is_debuff and not is_ignore  then
--					print('技能释放成功，没被挡住了')
--					if existEff[ data.type ] then
--						--效果动画
--						local sprite
--						local frames = display.newFramesWithImage(IMG_PATH.."image/scene/battle/pet/eff_flag/eff_"..data.type..".png" , tonumber( existEff[ data.type ] ) )
--						sprite = display.playFrames(
--							targetHero._cx, 
--							targetHero._cy,
--							frames,
--							0.15,
--							{
--								delay = 0.05,
--								onComplete = function()
--									sprite:removeFromParentAndCleanup(true)	-- 清除自己
--									
--									if existFlag[ data.type ] then
--										showText( targetHero )
--									end
--									
--									--改变锁定状态(必须人还活着)
--									if tonumber(tempData["hp"]) > 0 and existFlag[data.type]  then
--										lockEffect()
--									else
--										overHandler()
--									end
--									
--								end
--							}
--						)
--						sprite:setAnchorPoint( ccp(0.5 , 0.5) )
--						-- 添加到 特效层
--						
--						logic:getLayer("effect"):addChild( sprite )
--					end
--
--
--					return
--				end
--
--				-- 技能释放出来了，但被挡住了
--				if is_debuff and is_ignore  then
--					print('技能释放成功，但被挡住了')
--
--					local sprite
--					local frames = display.newFramesWithImage(IMG_PATH .. "image/scene/battle/pet/resist.png" , 6 )
--					sprite = display.playFrames(
--						targetSizeInfo._cx, 
--						targetSizeInfo._cy + ( tempData.group == 1 and 70 or -70 ),
--						frames,
--						0.15,
--						{
--							onComplete = function()
--								sprite:removeFromParentAndCleanup(true)	-- 清除自己
--								overHandler()
--							end
--						}
--					)
--					sprite:setAnchorPoint( ccp(0.5 , 0.5) )
--					logic:getLayer("effect"):addChild( sprite )
--
--					transition.scaleTo( sprite , {time = 0.2 , scale = 1.5 })
--					transition.moveTo( sprite , {time = 0.2 , y = targetSizeInfo._cy + ( tempData.group == 1 and 70 or -70 )})
--					return
--				end
--
--
--				-- 技能没释放成功
--				print('技能没释放成功')
--				if existLost[ data.type ] then
--					local lostSp = display.newSprite( IMG_PATH .. "image/scene/battle/pet/eff_flag/" .. data.type .. "_lost.png" )
--					setAnchPos( lostSp , targetSizeInfo._cx , targetSizeInfo._cy , 0.5 , 0.5 )
--					logic:getLayer("effect"):addChild( lostSp )
--					lostSp:setScale( 0.1 )
--					
--					transition.scaleTo( lostSp , { time = 0.2 , scale = 1.5, easing = "ELASTICOUT" ,
--					onComplete = function()
--						transition.scaleTo( lostSp , { delay = 0.2 , time = 0.2 , scale = 1 , easing = "ELASTICOUT" ,
--						onComplete = function()
--						lostSp:removeFromParentAndCleanup( true )
--						overHandler()
--						end})
--					end})
--				end
--				
--				
--			end
--		} )
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
		
		for key , v in  pairs(data.change) do
			renderEffect( v , key )
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