--[[

		被宠物技能攻击   中毒表现

]]--
local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")

function M:run( type , data )
	logic:pause( "poison" )

	--刷新血量
	local function upHp( tempData )
		--目标英雄
		local targetHero = requires(IMG_PATH , "GameLuaScript/Scene/battle/heroCell"):get( tempData.group , tempData.index )
		--中毒减血
		targetHero:setData("hp" , tempData.hp)
		targetHero:refreshViewHp()
		
		-- 显示掉血动画
		local effect_changeHp = requires(IMG_PATH,"GameLuaScript/Scene/battle/effect/changeHp")
		effect_changeHp:run( targetHero , tempData.hp_diff )
		
	end
	for key , v in pairs( data.change ) do
		upHp( v )
	end
	
	--改变flag状态
	local function upEffect( tempData )
		--目标英雄
		local targetHero = requires(IMG_PATH , "GameLuaScript/Scene/battle/heroCell"):get( tempData.group , tempData.index )
		local targetHeroData = targetHero:getData()[type..""]
		targetHeroData["new"..type] = tempData.keep
		if targetHeroData ~= nil then
			if tempData.keep == 0 then
				xpcall(function()
					targetHeroData.flag:removeFromParentAndCleanup( true )
				end, __G__TRACKBACK__)
				targetHeroData = nil
			else
				--降低透明度 表示石化效果影响正在降低
				targetHeroData.flag:setOpacity( tempData.keep / targetHeroData.keep * 255 )
			end
		end
		
	end
	for key , v in pairs( data.keep ) do
		upEffect( v )
	end
	logic:resume( "poison" )
	logic:resume( )
end

return M
