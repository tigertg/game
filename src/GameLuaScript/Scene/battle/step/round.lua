--[[

		刷新回合数

]]--
local M = {}

local logic = requires(IMG_PATH , "GameLuaScript/Scene/battle/logicLayer" )

function M:run( type , data )
	logic:setRound( data.round )
	logic:resume( )
end

return M