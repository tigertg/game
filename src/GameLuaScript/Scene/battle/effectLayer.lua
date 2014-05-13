--[[

特效层

]]--


local M = {}

local heroCell = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroCell")
local petLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/pet/petLayer")
local slideBossData
function M:create( data )
	local layer = display:newLayer()
	slideBossData = data.boss or {}

	return layer
end

function M:actions(data)
	--添加被克效果
	if data.atk and data.be_atk then
		
		local function showEff( tempData )
			local atkHero   = heroCell:get( data.atk[1].group , data.atk[1].index)	--攻击者
			local beAtkHero = heroCell:get( tempData.group    , tempData.index )	--被攻者
			local atkRole   = atkHero:getData( "role" )
			local beAtkRole = beAtkHero:getData( "role" )
			--相克关系
			local restrain = {
								[ "13" ] = "1克3" , 
								[ "21" ] = "2克1" , 
								[ "32" ] = "3克2" , 
								} 
			if restrain[ atkRole..beAtkRole.."" ] then
				local beAtkSize = beAtkHero:getPositionAndSize()
				
				local restrainSp = display.newSprite( IMG_PATH .. "image/scene/battle/effect/restrain.png" )
				
				local logic = requires( IMG_PATH , "GameLuaScript/Scene/battle/logicLayer")
				setAnchPos( restrainSp , beAtkSize._cx + 20 , beAtkSize._y + 50 , 0.5 , 0.5)
				
				
				--[[特效开始]]
				restrainSp:setScale(0.3)
				transition.scaleTo(restrainSp, {
					time = 0.1,
					scale = 2.5,
				})
				transition.scaleTo(restrainSp, {
					delay = 0.2,
					time = 0.2,
					scale = 1,
				})
				
				
				transition.fadeOut(restrainSp, {
					delay = 0.7,
					time = 0.3,
					onComplete = function()
						restrainSp:removeFromParentAndCleanup(true)	-- 清除自己
					end
				})
				
				logic:getLayer( "effect" ):addChild( restrainSp )
			end
		end
		for key , v in pairs(data.be_atk) do
			showEff(v)
		end
	end
	
	M:changeActions( data["change"] , data )
	
	--修改宠物怒气值
	if data.p1_sp ~= nil then petLayer:selfRefreshPetSp( data , 1 ) end
	if data.p2_sp ~= nil then petLayer:selfRefreshPetSp( data , 2 ) end
end

--[[ change 字段公用特效 ]]
function M:changeActions( change_data , data )
	if type(change_data) ~= "table" then return end
	for i = 1 , #change_data do
		-- 扣血
		local cur_data = change_data[i]
		local cur_hero = heroCell:get( cur_data["group"] , cur_data["index"] )
		cur_hero:setData("hp" , cur_data["hp"])
		cur_hero:refreshViewHp()
		
		-- 显示掉血动画
		local isCrit = ( isset(cur_data , "actions") and cur_data["actions"]["crit"] ) and true or false --是否是暴击掉血
		local effect_changeHp = requires(IMG_PATH,"GameLuaScript/Scene/battle/effect/changeHp")
		effect_changeHp:run( cur_hero , cur_data["hp_diff"] , { isCrit = isCrit } )

		--清除挂掉的人
		local function clear()
			local heroAction_die = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroAction/die")
			heroAction_die:normal( cur_hero , {
				onComplete = function()
					--死亡动画执行完毕
					heroCell:clear( cur_data["group"] , cur_data["index"] )
				end
			})
		end


		-- 附加动作
		local isFly = false
		if isset(cur_data , "actions") then

			--二级属性文字提示
			local attribEffect = requires(IMG_PATH,"GameLuaScript/Scene/battle/effect/twoAttribText")
			attribEffect:run(  cur_hero , cur_data["actions"] , data )
--			-- 闪避
--			if cur_data["actions"]["dodge"] then
--				local effect_dodge = requires(IMG_PATH,"GameLuaScript/Scene/battle/effect/dodge")
--				effect_dodge:run( cur_hero )
--			end
--
--			-- 暴击
--			if cur_data["actions"]["crit"] then
--				local effect_critical = requires(IMG_PATH,"GameLuaScript/Scene/battle/effect/critical")
--				effect_critical:run( cur_hero )
--			end
--
--			-- 击飞
--			if cur_data["actions"]["fly"] then
--				isFly = true
--				local effect_fly = requires(IMG_PATH,"GameLuaScript/Scene/battle/effect/fly")
--				effect_fly:run( cur_hero ,{ clear = clear})
--			end

		end

		-- 受击效果
		if cur_data["hp_diff"] < 0 then
			local heroAction_be_attack = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroAction/be_attack")
			heroAction_be_attack:normal( cur_hero )
		end
		
		--已方武将死亡
		if tonumber(cur_data["hp"]) <= 0 then
--			local handle
--			local function delayRealize()
--				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
--				handle = nil
--				clear()
--			end
--			handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(delayRealize , 0.5 , false)
--			--延迟死亡使后续一些
--			cur_hero:setVisible( false )
			--划动掉宝 敌方死亡触发
			
			clear()
			local dieCid = cur_hero:getData().cid or cur_hero:getData().npc_id
			if slideBossData.boss_cid == dieCid then
				local effect_slide = requires(IMG_PATH,"GameLuaScript/Scene/battle/effect/slide")
				local tempData = slideBossData or {}
				--出现slide证明当前英雄已死亡,需要执行清除
				effect_slide:run( cur_hero ,  tempData )
					
			end
		end


		--显示掉宝动画
		if cur_data["drop"] then
			local effect_dorp = requires(IMG_PATH,"GameLuaScript/Scene/battle/effect/drop")
			effect_dorp:run( cur_hero , cur_data["drop"] )
		end

	end
end

return M
