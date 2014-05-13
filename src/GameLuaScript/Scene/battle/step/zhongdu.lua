--[[

		轮次数展示

]]--
local M = {}

local logic = requires(IMG_PATH , "GameLuaScript/Scene/battle/logicLayer" )
local effectLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/effectLayer")
function M:run( type , data )
	logic:pause( "zhongdu" )
	--刷新血量
	local function upHp( tempData )
		effectLayer:changeActions( data["change"] , data )
		
--		--目标英雄
--		local targetHeroCell = requires(IMG_PATH , "GameLuaScript/Scene/battle/heroCell")
--		local targetHero = targetHeroCell:get( tempData.group , tempData.index )
--		--中毒减血
--		targetHero:setData("hp" , tempData.hp)
--		targetHero:refreshViewHp()
--		
--		-- 显示掉血动画
--		local effect_changeHp = requires(IMG_PATH,"GameLuaScript/Scene/battle/effect/changeHp")
--		effect_changeHp:run( targetHero , tempData.hp_diff )
--		
--		--清除死掉的人
--		local function clear()
--			local heroAction_die = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroAction/die")
--			heroAction_die:normal( targetHero , {
--				onComplete = function()
--					--死亡动画执行完毕
--					targetHeroCell:clear( tempData["group"] , tempData["index"] )
--				end
--			})
--		end
--		if tonumber(tempData.hp) <= 0 then
--			clear()
--		end
		
	end
	for key , v in pairs( data.change ) do
		upHp( v )
	end
	
	--改变flag状态
	local function upEffect( tempData )
		--目标英雄
		local targetHero = requires(IMG_PATH , "GameLuaScript/Scene/battle/heroCell"):get( tempData.group , tempData.index )
		local targetHeroData = targetHero:getData()[ type.."" ]
		
		
		targetHeroData["new"..type] = tempData.keep
		if targetHeroData ~= nil then
			if tempData.keep == 0 then
				xpcall(function()
					targetHeroData.flag:removeFromParentAndCleanup( true )
				end, __G__TRACKBACK__)
				targetHeroData = nil

				targetHero:setData( "last_effect" , nil)
			else
				--降低透明度 表示石化效果影响正在降低
				targetHeroData.flag:setOpacity( tonumber( tempData.keep ) / targetHeroData.keep * 255 )
			end
		end
		
	end
	for key , v in pairs( data.keep ) do
		upEffect( v )
	end
	logic:resume( "zhongdu" )
	logic:resume( )
end

return M