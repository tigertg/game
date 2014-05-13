collectgarbage("setpause"  ,  100)
collectgarbage("setstepmul"  ,  5000)


-- [[ 包含各种 Layer ]]


local currentLayer = {}	--标记当前存在的层
local M = {}
--targetID  可选 如果存在则直接定值到目标id

local Clayer = requires(IMG_PATH,"GameLuaScript/Scene/strengthen/skilllayer")--require "GameLuaScript/Scene/culture/culturelayer"

local info = requires(IMG_PATH,"GameLuaScript/Scene/common/infolayer")--require "GameLuaScript/Scene/common/infolayer"


function M:create( param )
	if not param.type or param.type == "skill_strenthen" then
		local scene = display.newScene("strengthen")
		
		---------------插入layer---------------------
		scene:addChild(Clayer:new(param):getLayer())
		local infothis = info:new("strengthen", 0,{title_text = IMG_PATH.."image/scene/strengthen/up_skill_title.png",closeCallback = function() 
				if param.mode == "petskill" then
					if param.types == 1 then
						switchScene("detail" , {
								detail = "skill",
								data = param.data,
								skillSeat = param.skillSeat,
								defaultSkill = true,
								
							})
					else
						switchScene("bag")
					end
				elseif param.mode == "petplainskill" then
					if param.types == 1 then
						switchScene("detail" , {
								detail = "skill",
								filter = param.filter,
								id = param.id,
								petID = param.petID,
								skillSeat = param.skillSeat, 
								
							})
					else
						switchScene("bag")
					end					
				elseif param.mode == "heroskill" then
					if param.types == 1 then
						switchScene("detail", {
							detail = "skill",
							id = param.id,
							heroData = param.heroData,
							skillSeat = param.skillSeat, 
						})
					else
						switchScene("bag")
					end
				end
			end})
		scene:addChild(infothis:getLayer())
		return scene
	else
		local scene = display.newScene( param.type )
		
		---------------插入layer---------------------
	--	scene:addChild(StrengthenLayer:new(0 , 0))
		local typeUI =  requires(IMG_PATH,"GameLuaScript/Scene/strengthen/"..param.type ):new( param )
		currentLayer = { type = typeUI }
		scene:addChild( typeUI:getLayer())
		
		---------------------------------------------
		----在场景退出时停止已开始的计时器
		function scene:onExit()
		
			if param.resumeCallback then
				param.resumeCallback()
			end
		end
		return scene
	end
end

return M
