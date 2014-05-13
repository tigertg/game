--[[

		释放宠物技能 玄晕（ 当前回合不出手直接跳过 ）

]]--
local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer" )

function M:run( type , data )
	logic:pause( "sleep" )
	
	local function upEffect( tempData )
		--目标英雄
		local targetHero = requires(IMG_PATH , "GameLuaScript/Scene/battle/heroCell"):get( tempData.group , tempData.index )
		local targetHeroData = targetHero:getData()[type..""]
		targetHeroData["new"..type] = tempData.keep
		
		if tempData.keep == 0 then
			targetHeroData.flag:removeFromParentAndCleanup( true )
			targetHeroData = nil
		else
			--降低透明度 表示石化效果影响正在降低
			targetHeroData.flag:setOpacity( tempData.keep / targetHeroData.keep * 255 )
		end
		
	end
	
	for key , v in pairs( data.keep ) do
		upEffect( v )
	end
	
	logic:resume( "sleep" )
	logic:resume( )
end

return M
