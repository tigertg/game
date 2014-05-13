--[[

	击飞 (击飞 特效)

]]


local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")


--[[执行特效]]
function M:run( hero , param )
	if type(param) ~= "table" then param = {} end


	--[[特效开始]]
--	local sprite
--	local frames = display.newFramesWithImage(IMG_PATH.."image/scene/battle/pet/eff_flag/recover.png" , 12)
--	sprite = display.playFrames(
--		hero._cx,
--		hero._cy,
--		frames,
--		0.05,
--		{
--			delay = 0.05,
--			onComplete = function()
--				sprite:removeFromParentAndCleanup(true)	-- 清除自己
--
--				if param.onComplete then param.onComplete() end
--			end
--		}
--	)
--	sprite:setAnchorPoint( ccp(0.5 , 0.5) )

	hero:setAnchorPoint( ccp(0.5 , 0.5) )
	local action1
	local action2
	local action3
	if hero:getData("_group") == 2 then
		action1 = transition.moveTo( hero , { time = 1 , x = hero.x , y = display.height + 144  } )
		action2 = transition.rotateTo( hero , { time = 1 , angle = 720 , easing = "ELASTICIN" } )
	else
		action1 = transition.moveTo( hero , { time = 1 , x = hero.x , y = 0 - 144 } )
		action2 = transition.rotateTo( hero , { time = 1 , angle = -720 , easing = "ELASTICIN" } )

	end

--	action3 = transition.scaleTo( hero , { time = 1 , scaleX = 1 , scaleY = 1 ,
--		onComplete = function()
--			param.clear()
--		end
--		} )
--	local action4 = transition.skewTo( hero , { time = 1 , x = 10 , y = 10 ,
--		onComplete = function()
--			param.clear()
--		end
--		} )

	-- 添加到 特效层
--	logic:getLayer("effect"):addChild( sprite )

	return true
end


return M
