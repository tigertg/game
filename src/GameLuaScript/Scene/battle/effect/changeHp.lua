--[[

	血量改变  数字变化  (向上漂的数字)

]]


local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")

--[[执行特效]]
function M:run( hero , num , param )
	if type(param) ~= "table" then param = {} end
	
	if tonumber( num ) == 0 then
		if param.onComplete then param.onComplete() end
		return
	end
	
	local group , group_width
	if param.isCrit then
		audio.playSound(IMG_PATH .. "sound/crit.mp3")
		--暴击掉血
		group , group_width = getImageNum( math.abs( num ) , COMMONPATH .. "cirt.png" , { offset = -10 } )
	else
		--掉血或者加血
		group , group_width = getImageNum( math.abs( num ) , num>0 and COMMONPATH .. "hp_green.png" or  COMMONPATH .. "hp.png" )
	end
	
	
	setAnchPos( group , hero._cx  , hero._cy , 0.5 )


	--[[特效开始]]
	group:setScale(0.3)
	transition.scaleTo(group, {
		time = 0.1,
		scale = 2.5,
	})
	transition.scaleTo(group, {
		delay = 0.2,
		time = 0.2,
		scale = 1,
	})
	
	transition.moveTo(group, { delay = 0.6 , time = 0.4, x = hero._cx , y = hero._cy + 100  })
	
	transition.fadeOut(group, {
		delay = 0.7,
		time = 0.3,
		onComplete = function()
			group:removeFromParentAndCleanup(true)	-- 清除自己
			if param.onComplete then param.onComplete() end
		end
	})
	
	-- 添加到 特效层
	logic:getLayer("effect"):addChild( group )

end
return M
