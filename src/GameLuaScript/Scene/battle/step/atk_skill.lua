--[[

技能攻击

]]


local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local heroCell = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroCell")
local effectLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/effectLayer")
local ShowSkill = requires(IMG_PATH,"GameLuaScript/Scene/battle/effect/showSkill")
local skillConfig = requires(IMG_PATH,"GameLuaScript/Config/Skill")

local heroAction_move = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroAction/move")
local heroAction_attack = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroAction/attack")
local heroAction_be_attack = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroAction/be_attack")

--[[执行]]
function M:run( type , data )
	
	-- 攻击方
	local atk_data = data["atk"][1]		-- 普通攻击，肯定只有一个攻击者
	local atk_hero = heroCell:get( atk_data["group"] , atk_data["index"] )
	local isBigSkill = false	--是否是三星级以上技能
	-- 被攻击方
--	local moreSkill = { ["3008"] = "3008" , ["3010"] = "3010" } --攻击多人，但不是攻击所有敌方成员
	local be_atk_data = data["be_atk"][1]	-- 普通攻击，肯定只有一个被攻击者
	--查找多人攻击的最左边被攻击者，方便效果定位
--	if moreSkill[ data.skill_cid .. "" ] then
--		local tempIndex	= data["be_atk"][1]["index"]
--		for i = 1 , #data["be_atk"] do
--			if tonumber( tempIndex ) > tonumber( data["be_atk"][i]["index"] ) then
--				tempIndex = data["be_atk"][i]["index"]
--				be_atk_data = data["be_atk"][i]
--			end
--		end
--	end
	

	local be_atk_hero = heroCell:get( be_atk_data["group"] , be_atk_data["index"] )
	--所有被攻击者跳跃动画
	local function beAtkAction()
		for i = 1 , #data["be_atk"] do
			local curData = data["be_atk"][i]
			local tempHero = heroCell:get( curData["group"] , curData["index"] )
			heroAction_move:jumpOnce( tempHero , { noRecover = true })
		end
	end
	

	
	--存在的技能效果
	local haveSkill = { 
						["3901"]  = 4  ,
						["3902"]  = 4  ,
						["3903"]  = 4  , 
						["3904"]  = 4  ,
						["3905"]  = 4  ,
						["3906"]  = 4  ,
						["3907"]  = 5  ,
						["3908"]  = 4  ,
						["3909"]  = 4  ,
						["3910"]  = 4  ,
						["3911"]  = 4  ,
						["3912"]  = 4  ,
						["3913"]  = 4  ,
						["3914"]  = 4  ,
						["3915"]  = 4  ,
						["3916"]  = 4  ,
						["3917"]  = 4  ,
						}
						
	--已经存在技能文字
	local converSKillCid = skillConfig[ data.skill_cid.."" ].effect_id .. ""
	--攻击效果
	local function atk_Eff( tempParams )
		local effSprite
		local effFrames = display.newFramesWithImage( IMG_PATH.."image/scene/battle/skillAction/".. converSKillCid ..".png" , haveSkill[ converSKillCid ] )
		effSprite =display.playFrames( 0  , 0  , effFrames , 0.15 , { onComplete =
																		 function() 
																			effSprite:removeFromParentAndCleanup( true ) 
																			if isBigSkill then
																				logic:skillHide(true) 
																			end
																			if tempParams.overHandler then tempParams.overHandler() end
																			if tempParams.offset then setAnchPos( logic:getLayer( tempParams.offset.targetLayer), 0 , 0 ) end
																		 end
																		 } )
		
		local targetSize = be_atk_hero:getPositionAndSize()
		local effectSize = effSprite:getContentSize()
		--效果坐标
		local effectPoint = {}
		--单体攻击(特效中心点与人物中心点对齐)
		if 	   converSKillCid == "3901"  then effectPoint.x , effectPoint.y = targetSize._cx - effectSize.width / 2 , targetSize._cy - effectSize.height / 2 + 26
		elseif converSKillCid == "3902"  then effectPoint.x , effectPoint.y = targetSize._cx - effectSize.width / 2 , targetSize._cy - effectSize.height / 2 
		elseif converSKillCid == "3903"  then effectPoint.x , effectPoint.y = targetSize._cx - effectSize.width / 2 , targetSize._cy - effectSize.height / 2 
		elseif converSKillCid == "3904"  then effectPoint.x , effectPoint.y = targetSize._cx - effectSize.width / 2 , targetSize._cy - effectSize.height / 2 
		elseif converSKillCid == "3905"  then effectPoint.x , effectPoint.y = targetSize._cx - effectSize.width / 2 , targetSize._cy - effectSize.height / 2
		elseif converSKillCid == "3908"  then effectPoint.x , effectPoint.y = targetSize._cx - effectSize.width / 2 , targetSize._cy - effectSize.height / 2
		elseif converSKillCid == "3909"  then effectPoint.x , effectPoint.y = targetSize._cx - effectSize.width / 2 , targetSize._cy - effectSize.height / 2 
		elseif converSKillCid == "3910"  then effectPoint.x , effectPoint.y = targetSize._cx - effectSize.width / 2 , targetSize._cy - effectSize.height / 2 
		elseif converSKillCid == "3911"  then effectPoint.x , effectPoint.y = targetSize._cx - effectSize.width / 2 , targetSize._cy - effectSize.height / 2 + 40
		elseif converSKillCid == "3914"  then effectPoint.x , effectPoint.y = targetSize._cx - effectSize.width / 2 , targetSize._cy - effectSize.height / 2
		elseif converSKillCid == "3915"  then effectPoint.x , effectPoint.y = targetSize._cx - effectSize.width / 2 , targetSize._cy - effectSize.height / 2
		elseif converSKillCid == "3917"  then effectPoint.x , effectPoint.y = targetSize._cx - effectSize.width / 2 - 30 , targetSize._cy - effectSize.height / 2
		--全体攻击(全体攻击，效果从x轴10像素处开始)
		elseif converSKillCid == "3906"  then effectPoint.x , effectPoint.y = 10 , targetSize._cy - effectSize.height / 2
		elseif converSKillCid == "3907"  then effectPoint.x , effectPoint.y = 10 , targetSize._cy - effectSize.height / 2 
		elseif converSKillCid == "3912"  then effectPoint.x , effectPoint.y = 10 , targetSize._cy - effectSize.height / 2
		elseif converSKillCid == "3913"  then effectPoint.x , effectPoint.y = 10 , targetSize._cy - effectSize.height / 2
		elseif converSKillCid == "3916"  then effectPoint.x , effectPoint.y = 10 , targetSize._cy - effectSize.height / 2
		end
		
		--offset值由showSkill传过来
		if tempParams.offset then
			setAnchPos(effSprite , effectPoint.x  , effectPoint.y + tempParams.offset.valueY , 0 , 0 )
		else
			setAnchPos(effSprite , effectPoint.x  , effectPoint.y , 0 , 0 )
		end
		
		logic:getLayer("effect"):addChild( effSprite )
	end
	--被攻击者效果
	local function be_atkEff( tempParams )
		if not tempParams then tempParams = {} end

		
		-- 攻击效果(刀光)
		heroAction_attack:skill( atk_hero , be_atk_hero , {
			onComplete = function()
				atk_Eff( tempParams )
--				transition.shake()
				beAtkAction()
				-- 掉血 刷新宠物怒气值
				effectLayer:actions( data )
				if isBigSkill then
					audio.playSound(IMG_PATH .. "sound/atk_skill.mp3")
				else
					audio.playSound(IMG_PATH .. "sound/small_atk_skill.mp3")
				end
				-- 恢复战斗进程
				local handle
				local function callback()
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
					handle = nil
					logic:resume()
				end
				handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(callback, 0.3, false)
			end
		})
	
	end
	
	
	
	
	--攻击者效果表现 大于三星则单独页面表现效果
	if tonumber( skillConfig[ data.skill_cid .. "" ].star ) > 3 then
		isBigSkill = true
		ShowSkill:run( atk_hero , be_atk_hero , { skillID = data.skill_cid , callBack = be_atkEff })
	else
		isBigSkill = false
		--添加技能名称
		local function commonEff()
			local atkHeroSize = atk_hero:getPositionAndSize()
			
			local sprite
			local frames = display.newFramesWithImage(IMG_PATH .. "image/scene/battle/def_eff.png" , 7 )
			sprite = display.playFrames(
				atkHeroSize._cx, 
				atkHeroSize._cy,
				frames,
				0.1,
				{
					onComplete = function()
						sprite:removeFromParentAndCleanup(true)	-- 清除自己
					end
				}
			)
			sprite:setAnchorPoint( ccp(0.5 , 0.5) )
			if atk_data["group"] == 2 then sprite:setFlipY(true) end
			-- 添加到 特效层
			logic:getLayer("effect"):addChild( sprite )
			
			--[[播放动画]]
			heroAction_move:jumpOnce( atk_hero , { noRecover = true })
			
			--攻击者 技能名称 弹出
	 		local atk_heroSize = atk_hero:getPositionAndSize()
	 		
			local skillTextBg = display.newSprite(IMG_PATH .. "image/scene/battle/skil_text_bg.png")
			local bgSize = skillTextBg:getContentSize()
			local skillText = display.newSprite(IMG_PATH .. "image/scene/battle/skillAction/text_" .. data.skill_cid .. ".png")
			local skillTextSize = skillText:getContentSize()
			setAnchPos( skillText , bgSize.width / 2 , 5 , 0.5 )
			skillTextBg:addChild( skillText )
			
			setAnchPos( skillTextBg , atk_heroSize._cx  ,atk_heroSize._y + atk_heroSize._height , 0.5 )
			logic:getLayer("effect"):addChild( skillTextBg )
			
			
			skillTextBg:setScale(0.3)
			transition.scaleTo(skillTextBg, {
				time = 0.6,
				scale = 1,
				easing = "ELASTICOUT",
			})
		
			transition.fadeOut(skillTextBg, {
				delay = 0.8,
				time = 0.4,
				onComplete = function()
					skillTextBg:removeFromParentAndCleanup(true)	-- 清除自己
				end
			})
		end
		
		
		--攻击者自身效果表现
		local startFun  = CCCallFunc:create(function() atk_hero:setAnchorPoint( ccp( 0.5 , 0.5) ) end )
		local flipx  = CCOrbitCamera:create( 0.3 , 1 , 0 , 0 , 360 , 0 , 0 )
		local delay = CCDelayTime:create(0.1)
		local overFun  = CCCallFunc:create( function() atk_hero:setAnchorPoint( ccp( 0 , 0) ) end )
		
		local array = CCArray:create()
		array:addObject(startFun)
		array:addObject( CCDelayTime:create(0.5) )
		array:addObject( CCCallFunc:create(commonEff) )
		array:addObject(flipx)
		array:addObject(delay)
		array:addObject(overFun)
		array:addObject(CCCallFunc:create(be_atkEff))
		atk_hero:runAction( CCSequence:create(array) )
	end
	

	
	
--[[
	-- 变大过去后的回调
	onComplete = function()
		-- 挥舞动作
		heroAction_attack:wave( atk_hero , {
			onComplete = function()
				-- 掉血
				effectLayer:actions( data )

				-- 回来
				heroAction_move:moveback( atk_hero , {
					onComplete = function()
						-- 恢复战斗进程
						logic:resume()
					end,
				})
			end
		})

		-- 攻击效果(刀光)
		heroAction_attack:normal( atk_hero )
	end]]--
end


return M
