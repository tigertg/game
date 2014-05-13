--[[

		被 石化

]]--
local M = {}

local logic = requires(IMG_PATH , "GameLuaScript/Scene/battle/logicLayer" )

function M:run( type , data )
--	logic:pause( "stone" )
--[[ type = "stone"
- data = {
-     "change" = {
-         1 = {
-             "group" = 2
-             "index" = 3
-             "keep"  = 1
-         }
-     }
- }]]--
	
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
--	
--	logic:resume( "stone" )
	logic:resume( )
end

return M