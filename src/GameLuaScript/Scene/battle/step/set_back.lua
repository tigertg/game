--[[

		替补武将换位

]]--
local M = {}
local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local backHeroCell = requires(IMG_PATH,"GameLuaScript/Scene/battle/backHeroCell")
local heroLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroLayer")


function M:run( type , data )

--	logic:pause( "set_back" )

	local backHero1 = backHeroCell:get( data.group , data["0"] )
	local backHero2 = backHeroCell:get( data.group , data["1"] )
	
	if not backHero2 and not backHero1 then
		logic:resume()
		return
	end
	
	backHero1:removeFromParentAndCleanup(true)
	backHero2:removeFromParentAndCleanup(true)
	
	local backHeroData1 = backHero1:getData()
	local backHeroData2 = backHero2:getData()

	local tempIndex = backHeroData1._index
	backHeroData1._index = backHeroData2._index
	backHeroData2._index = tempIndex

--	backHeroCell:clear( data.group , data["0"] )
--	backHeroCell:clear( data.group , data["1"] )

	local tempBackHero = backHeroCell.new( backHeroData1 )
	heroLayer:setBackOneHero(tempBackHero , tempBackHero:getData("_group") , tempBackHero:getData("_index") )
	tempBackHero:setEnabled( true )

	tempBackHero = backHeroCell.new( backHeroData2 )
	heroLayer:setBackOneHero(tempBackHero , tempBackHero:getData("_group") , tempBackHero:getData("_index") )
	tempBackHero:setEnabled( true )

--	logic:resume( "set_back" )
	logic:resume( )

end

return M
