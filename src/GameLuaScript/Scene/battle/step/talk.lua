--[[

对话

]]


local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local heroCell = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroCell")
local effectLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/effectLayer")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")

--[[执行]]
function M:run( type , data )
	logic:pause("talk")
	local battleData = DATA_Battle:get("report")	--战斗数据
	local talkConfig = battleData.prepare.talk[ data.key .. ""]		--对话培植数据
	if not logic:getSelfAgent() then
		for key , v in pairs( battleData["1"] ) do
			if v.type == "queue" then
				logic:setSelfAgent( v.data.p1[1].cid )
				break
			end
		end
	end 
	
	local curIndex = 1	--当前对话索引
	local PATH = IMG_PATH .. "image/scene/battle/"
	local talkLayer = display.newLayer()--对话层
	local talkText
	local roleImage		--角色图像
	local talkFrame = display.newSprite( COMMONPATH .. "dialog_bg.png")	--对话框背景
	talkLayer:addChild( talkFrame )
	
	
	
	local mask
--	local handle 
	local function createTalk()
		local data = talkConfig[curIndex]
		if roleImage then
			roleImage:removeFromParentAndCleanup(true)
			roleImage = nil
		end
		
		if talkText then
			talkText:removeFromParentAndCleanup(true)
		end
		
--		if handle ~= nil then
--			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
--			handle = nil
--		end
--		
		if data then
			local isSelf = data.who == 0 	--是否是自己一方
			local curRoleCid = isSelf and logic:getSelfAgent( ) or data.who
			local isBig = true
			if data.who == "songjiang2" then
				isSelf = false
				roleImage = display.newSprite( IMG_PATH .. "image/scene/battle/" .. data.who .. ".png" )
				isBig = true
			elseif data.who == -1 then
				isSelf = true
				roleImage = nil
			else
				roleImage = display.newSprite( IMG_PATH .. "image/hero/" ..  getImageByType( curRoleCid , "b" , true) )
				-- 卡牌大图
				
				local cid_type = getCidType( curRoleCid )
				if cid_type == "npc" then
					if getConfig("npc" , curRoleCid , "logo_id") >= 18000 then
						isBig = false
					end
				end
			end
			
			
			
			
			--文字
			local dimensions_width = roleImage and 220 or 390
			talkText = display.strokeLabel( data.str , isSelf and 35 or 240 , isSelf and 250 or 530 , 20 ,  ccc3(0xff , 0xff , 0xff )  ,  nil , nil , {
				dimensions_width = dimensions_width,
				dimensions_height = 120,
				align = 0
			})

			
			if roleImage then
				roleImage:setScale( isBig and 1 or 1.5 )
				setAnchPos( roleImage , isSelf and 250 or 0  , isSelf and 250 or 508   )

				talkLayer:addChild( roleImage )
			end
			
			setAnchPos( talkFrame , display.cx , isSelf and 239 or 517  , 0.5 )
			talkFrame:setFlipX( isSelf )
			talkLayer:addChild( talkText  )
			
			--自动刷新
--			handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(createTalk , 7 , false)
		else
			logic:resume("talk")
			logic:resume()
			mask:remove()
			
		end
		curIndex = curIndex + 1
	end
	
	mask = KNMask:new( {item = talkLayer , click = createTalk , opacity = 200 } )
	local scene = display.getRunningScene()
	scene:addChild(mask:getLayer())
	
	createTalk()
end

return M
