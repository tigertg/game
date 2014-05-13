collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]
local PetLayer = requires(IMG_PATH,"GameLuaScript/Scene/petupdata/petupdatalayer")--require "GameLuaScript/Scene/pet/petlayer"

local info = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")--require "GameLuaScript/Scene/common/infolayer"


local M = {}

function M:create(id)
	local scene = display.newScene("petupdata")
	
	---------------插入layer---------------------
	scene:addChild(PetLayer:new(id))
	---------------------------------------------
	local infothis = info:new("petupdata", 0,{title_text = IMG_PATH.."image/scene/pet/title_up.png",closeCallback = function() switchScene("pet",{id = id}) end})
	scene:addChild(infothis:getLayer())
	
	return scene
end

return M
