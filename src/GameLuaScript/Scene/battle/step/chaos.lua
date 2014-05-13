--[[

		混乱（只处理效果） 不需理会数据处理

]]


local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")

--[[执行]]
function M:run( type , data )
--- "<var>" = {
---     "keep" = {
---         1 = {
---             "group" = 2
---             "index" = 0
---             "keep"  = 0
---         }
---     }
--- }
 	--刷新数据
	local function upData( tempData )
		--目标英雄
		local targetHero = requires( IMG_PATH,"GameLuaScript/Scene/battle/heroCell"):get( tempData.group , tempData.index )
		local targetHeroData = targetHero:getData()[type..""]
		
		targetHeroData["new"..type] = tempData.keep
		
		if tempData.keep == 0 then
			targetHeroData.flag:removeFromParentAndCleanup( true )
			targetHeroData = nil
		else
			--降低透明度 表示效果影响正在降低
			targetHeroData.flag:setOpacity( tempData.keep / targetHeroData.keep * 255 )
		end
	end
	for key , v in pairs( data.keep ) do
		upData( v ) 
	end
	 
	logic:resume()
end


return M
