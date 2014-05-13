--[[

英雄动作 (死亡)

]]


local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local heroCell = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroCell")


--[[执行特效]]
function M:normal( hero , param )
	if type(param) ~= "table" then param = {} end

	transition.playSprites(hero , "fadeOut" , {
		time = 0.3,
		onComplete = function()
			if param.onComplete then param.onComplete() end
		end
	})


	return true
end


return M
