--[[

		反击效果处理(后台处理反击逻辑，前台直接恢复游戏即可)

]]


local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
--[[执行]]
function M:run( type , data )
	local atk = requires(IMG_PATH,"GameLuaScript/Scene/battle/step/atk")
	atk:run( "ctatk" , data )
--	logic:resume()
end


return M
