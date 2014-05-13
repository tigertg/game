--[[

		英雄死亡掉落宝物

]]--

local M = {}
local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")

function M:run( hero , params )
	params = params or {}
	
	
end
function M:run2( hero , param )
--	logic:pause( "drop" )		--暂停游戏

	local layer =display.newLayer()
	local heroPoint = hero:getPosition()	--英雄位置
	local heroSize = hero:getContentSize()	--英雄大小

	local imagePath		--展 示的图片地址
	param.type = param.type or  "silver"
	if param.type == "silver" then	imagePath = IMG_PATH .. "image/scene/battle/" .. param.type .. ".png"	--银两
	elseif param.type == "weapon" then	imagePath = IMG_PATH .. "image/equip/" .. param.id .. ".png"--武器
	end

	--掉落物品
	local reward = display.newSprite( imagePath )
	reward:setPosition( hero.x , hero.y )
	layer:addChild( reward )



	--清除自己
	local  function clearSelf()
		reward:removeFromParentAndCleanup(true)
		reward = nil

		layer:removeFromParentAndCleanup(true)
		layer = nil

--		logic:resume( "drop" )		--恢复游戏
	end
	--结束动画时间
	local overActionTime = 0.3
	--开始动画时间
	local startActionTime = 0.5

	--结束 动画
	local function disappear()
		local actions = CCArray:create()
		--缩放控制
		local actionScales = CCArray:create()
		actionScales:addObject( CCScaleTo:create( overActionTime , 0.2 ) )
		actionScales:addObject( CCMoveTo:create( overActionTime , ccp(display.width , display.height) ) )
		actions:addObject( CCSpawn:create( actionScales ) )

		actions:addObject( CCCallFunc:create( clearSelf ) )

		reward:runAction(  CCSequence:create( actions ) )
	end

	--物品掉落后延迟消失
	local function dropDelay()
		local handle

		local function delayRealize()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
			handle = nil
			disappear()
		end

		handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(delayRealize , 0.3 , false)

	end

	local startAction = CCArray:create()

	if hero:getData()._group == "temp" then
	--用于划动掉宝效果
		reward:setPosition( hero.x + heroSize.width / 2 , hero.y + heroSize.height )
		startAction:addObject( CCJumpTo:create( startActionTime , ccp( hero.x + heroSize.width + 60  , hero.y ) , 50 , 1 ) )
	else
	--正常战斗掉落效果
		startAction:addObject( CCJumpTo:create( startActionTime , ccp( hero.x + heroSize.width / 2 , display.cy ) , 100 , 1 ) )
	end

	startAction:addObject( CCCallFunc:create( dropDelay ) )

	--开始动画
	reward:runAction( CCSequence:create( startAction ) )


	logic:getLayer("effect"):addChild( layer )
	return  true
end

return M
