--[[

普通攻击

]]


local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")

--[[执行]]
function M:run( type , data )
	-- echoLog("BATTLE" , "sort")

	logic:resume()
end


return M
