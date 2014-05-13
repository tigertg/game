--[[

	二级属性文字

]]


local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local HeroCell =  requires(IMG_PATH,"GameLuaScript/Scene/battle/heroCell")
--[[执行特效]]
function M:run( _hero , _data , allData )
	if not param then param = {} end
	
--	--被攻攻击者展示
--	local beAtcGather = {
--						 ["crit"]     = "crit" ,	--暴击
--						 ["impale"]   = "impale" ,	--空刺
--						 ["block"]    = "block" ,	--格挡
--						 ["dodge"]    = "dodge" ,	--闪避
--						 ["ctatk"]    = "ctatk" ,	--反击
--						 ["thump"]    = "thump" ,	--重击
--						 ["confront"] = "confront",	--招架
--						 ["kill"]     = "kill" ,	--必杀
--						}
--	--攻击者展示
--	local atkGather = {
--						 ["hit"]      = "hit" ,		--命中
--						 ["double"]   = "double" ,	--连击
--						}

	--被攻攻击者展示
	local beAtcGather = {
						 ["block"]    = "block" ,	--格挡
						 ["dodge"]    = "dodge" ,	--闪避
						 ["ctatk"]    = "ctatk" ,	--反击
						}
	--攻击者展示
	local atkGather = {
						["crit"]     = "crit" ,		--暴击
						["hit"]   	 = "hit" ,		--命中
						["kill"]     = "kill" ,		--必杀
						}
						
					
	local time = 0.4
	
	-- 添加到 特效层
	for key , v in pairs( _data ) do
		local function createAction( type )
			local hero
			if atkGather[type..""] then
				hero = HeroCell:get( allData.atk[1]["group"] , allData.atk[1]["index"] )
			else
				hero = _hero
			end
			--[[文字特效]]
			local group = display.newSprite(IMG_PATH.."image/scene/battle/effect/" .. type .. "_text.png")
			display.align(group , display.CENTER , hero._cx , hero._y + hero._height + 20 )
			
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
					if param.onComplete then param.onComplete() end
				end
			})
			
			-- 添加到 特效层
			logic:getLayer("effect"):addChild( group )
		end
		
		createAction( key )
	end





end
return M
