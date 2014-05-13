--[[

战斗队列排列

]]--


local M = {}
local disseats = {}
local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local heroCell = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroCell")
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local replaceId = -1
function M:create()
	local content = display:newLayer()

	heroCell:init( true )

	return content
end

-- 设置英雄位置
function M:setOneHero(hero , group , index , callFun )
	local offset_y = (group == 1 and 200) or 493
	
	--hero:ignoreAnchorPointForPosition(false)
	hero:setAnchorPoint( ccp(0 , 0) )
	hero:setPosition( 12 + index * 116 , offset_y )


	local groupLayer = group == 1 and "selfHero" or "enemyHero"
	logic:getLayer( groupLayer ):addChild( hero )

	-- 预存储武将的位置与大小
	local size = hero:getPositionAndSize()
	for k , v in pairs(size) do
		hero[k] = v
	end

	if callFun ~= nil then
		hero:setClickCallback( callFun )
	end

	return hero
end

function M:setBackOneHero(backHero , group , index , callFun )

	index = index - backHero:getDieNum( group )
	local offset_x = (group == 1 and ( 260 + (index - 1) * 70 ) ) or ( 87 + (index - 1) * 70 )
	local offset_y = (group == 1 and 110 ) or 670

	backHero:setPosition( offset_x , offset_y )
	backHero:setAnchorPoint( ccp(0 , 0) )
	
	logic:getLayer( "backHero" ):addChild( backHero )

	-- 预存储武将的位置与大小
	local size = backHero:getPositionAndSize()
	for k , v in pairs(size) do
		backHero[k] = v
	end


	return hero
end

--返回所有按钮
function M:getDisseat()
	return disseats
end
--换位旧id保存
function M:setReplaceId( index )
	replaceId = index
end
return M
