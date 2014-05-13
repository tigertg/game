--[[

		轮次数展示

]]--
local M = {}

local logic = requires(IMG_PATH , "GameLuaScript/Scene/battle/logicLayer" )

function M:run( type , data )

	--刷新数据
	local function upData( tempData )
		--目标英雄
		local targetHero = requires( IMG_PATH,"GameLuaScript/Scene/battle/heroCell"):get( tempData.group , tempData.index )
		local targetHeroData = targetHero:getData()[type..""]
		
		targetHeroData["new"..type] = tempData.keep
		
		if tempData.keep == 0 then
			targetHeroData.flag:removeFromParentAndCleanup( true )
			targetHeroData = nil

			targetHero:setData( "last_effect" , nil)
		else
			--降低透明度 表示效果影响正在降低
			targetHeroData.flag:setOpacity( tempData.keep / targetHeroData.keep * 255 )
		end
	end
	for key , v in pairs( data.keep ) do
		upData( v ) 
	end

	
	logic:resume( )
end

return M