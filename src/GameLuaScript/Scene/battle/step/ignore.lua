--[[

		后台垃圾数据

]]--
local M = {}

local logic = requires(IMG_PATH , "GameLuaScript/Scene/battle/logicLayer" )
local PATH = IMG_PATH .. "image/scene/battle/"
function M:run( type , data )
	logic:resume( )
end

return M