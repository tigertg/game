--[[

战斗背景

]]


local M = {}


local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local isSkip = false	--默认没有跳过

function M:create( )
	local layer = display.newLayer()

	-- 初始化
	isSkip = false


	-- 添加战斗背景中部
	local bg = display.newSprite(IMG_PATH.."image/scene/battle/battle_bg.png")
	display.align(bg , display.CENTER , display.cx , display.cy)
	layer:addChild(bg)

	-- 添加战斗背景顶部
	local bg_top = display.newSprite(IMG_PATH.."image/scene/battle/bg_bottom.png")
	local topSize = bg_top:getContentSize()
	display.align(bg_top , display.TOP_LEFT , topSize.width , display.top - topSize.height)
	bg_top:setRotation(180)
	layer:addChild(bg_top)
	--战斗背景底部
	local bg_bottom = display.newSprite(IMG_PATH.."image/scene/battle/bg_bottom.png")
	display.align(bg_bottom , display.BOTTOM_LEFT , display.left , display.bottom)
	layer:addChild(bg_bottom)

    return layer
end
--返回是否点击跳过按钮
function M:getIsSkip( )
	return isSkip
end
function M:setIsSkip( flag )
	isSkip = flag
end

return M
