--[[

	引导战斗中 技能释放引导

]]


local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")

--[[执行]]
function M:run( type , data )
	logic:pause("click")
	
	local scene = display.getRunningScene()
	local mask = PlayerGuide:createSprite()
	
	local arrows = display.newSprite( IMG_PATH .. "image/arrow.png")
	setAnchPos(arrows , 216 , 200 , 0.5 , 0.5)
	
	
	local function actionFun()
		transition.moveTo(arrows , { y = 160 , time = 0.8 , onComplete =
					 function()
					  transition.moveTo(arrows , { y = 200 , time = 0.8 , onComplete = actionFun })
				  	 end })
	end
	actionFun()
	
	
	local function clickFun()
		scene:removeChild(mask , true)
		logic:resume("click")
		logic:resume()
	end
	mask:show( 89 , 89 , ccp( 171 , 14 ) , 0.7 , clickFun , function()end )
	mask:addChild( arrows )
	scene:addChild(mask , 100 )
end

return M
