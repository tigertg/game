--[[

	血拼模式

]]


local M = {}

local logic = requires(IMG_PATH,"GameLuaScript/Scene/battle/logicLayer")
local KNBar = requires(IMG_PATH,"GameLuaScript/Common/KNBar")
local KNBtn = requires(IMG_PATH, "GameLuaScript/Common/KNBtn")
--[[执行]]
function M:run( type , data )
	local mask
	logic:pause()
	
	local PATH = IMG_PATH .. "image/scene/battle/battleWithHp/"
	local layer = display.newLayer()
	
	local bg = display.newSprite( IMG_PATH .. "image/scene/admission/bg.png" )
	local additionBg = display.newSprite( PATH .. "addition_bg.png" )
	
	local titleBg = display.newSprite( IMG_PATH .. "image/scene/fb/title_bg.png" )
	local titleText = display.newSprite( PATH .. "title_text.png" )
	
	local flagSp = display.newSprite( PATH .. "flag.png" )
	
	
	setAnchPos( bg , 0 , 0 , 0 , 0 )
	setAnchPos( additionBg , 0 , 0 , 0 , 0 )
	setAnchPos( titleBg , display.cx , 769 , 0.5 , 0.5 )
	setAnchPos( titleText , display.cx , 769 , 0.5 , 0.5 )
	setAnchPos( flagSp , display.cx , 135 , 0.5 , 0.5 )
	
	layer:addChild(bg)
	layer:addChild(additionBg)
	layer:addChild(titleBg)
	layer:addChild(titleText)
	
	
	local selfHpBar = KNBar:new("red" , 0 , 700 , { curValue = data[ 1 .. "" ] , maxValue = data[ 1 .. "" ] , isDrag = true , direction = 0 } )
	selfHpBar:setIsShowText( false )
	local enemyHpBar = KNBar:new("blue" , display.cx , 700 , { curValue = data[ 2 .. ""  ] , maxValue = data[ 2 .. ""  ] , isDrag = true , direction = 1 } )
	enemyHpBar:setIsShowText( false )
	
	layer:addChild(selfHpBar)
	layer:addChild(enemyHpBar)
	layer:addChild(flagSp)
	
	
	
	--数字刷新部分
	local quicken = 10	--加速
	local cut = math.round( ( data[ 1 .. ""] > data[ 2 .. ""] and data[ 2 .. ""] or data[ 1 .. ""] ) / 50 )
	local isExistZero = false
	local function refreshNum( _target , num  , group )
		if isExistZero then
			layer:removeFromParentAndCleanup( true )
			mask:remove()
			logic:resume()
			return
		end
		if num < 0 then num = 0 end
		
		if num == 0 then 
			isExistZero = true 
			return 
		end
		
		if group == 1 then
			selfHpBar:setActionPercent( num / data[ 1 .. ""] )
		else
			enemyHpBar:setActionPercent( num / data[ 2 .. ""] )
		end
		
		num = num - cut
		cut = cut + 5
		local target = _target
		if target then target:removeFromParentAndCleanup( true ) end
		
		
		target = getImageNum( num , PATH .. "num.png" , group )
		setAnchPos( target , group == 1 and 120 or 360 , 180  , 0.5 , 0.5 )
		layer:addChild( target )
		
		
		
		
		local function delayFun()
			refreshNum( target , num  , group )
		end
		local handler
		local function delayRealize()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handler)
			handler = nil
			delayFun()
		end
		handler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(delayRealize , 0.1 , false)
		
	end
	
	refreshNum( nil , data[ 1 .. ""] , 1 )
	refreshNum( nil , data[ 2 .. ""] , 2 )
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	--动画效果部分
	local playTime = 0.2
	local leftSp
	local leftFrames = display.newFramesWithImage(PATH .. "left.png" , 8 )
	leftSp = display.playFrames(
		150 , 
		display.cy + 15,
		leftFrames,
		playTime,
		{
			forever = true ,
			onComplete = function()
				leftSp:removeFromParentAndCleanup(true)	-- 清除自己
			end
		}
	)
	leftSp:setAnchorPoint( ccp(0.5 , 0.5) )
	layer:addChild( leftSp )
	
	local rightSp
	local rightFrames = display.newFramesWithImage(PATH .. "right.png" , 7 )
	rightSp = display.playFrames(
		330 , 
		display.cy + 15 ,
		rightFrames,
		playTime,
		{
			forever = true ,
			onComplete = function()
				rightSp:removeFromParentAndCleanup(true)	-- 清除自己
			end
		}
	)
	rightSp:setAnchorPoint( ccp(0.5 , 0.5) )
	layer:addChild( rightSp )
	
	
	local rightSp
	local rightFrames = display.newFramesWithImage(IMG_PATH .. "image/scene/battle/skillAction/3903.png" , 4 )
	rightSp = display.playFrames(
		230 , 
		display.cy + 15 ,
		rightFrames,
		playTime,
		{
			forever = true ,
			onComplete = function()
				rightSp:removeFromParentAndCleanup(true)	-- 清除自己
			end
		}
	)
	rightSp:setAnchorPoint( ccp(0.5 , 0.5) )
	layer:addChild( rightSp )
	
	
	
	
	
	
	
	
	
	
	
	
	--人物图像部分处理
	local roleData = nil
	local data = DATA_Battle:get("report")[3 .. "" ]
	for i = 1 , #data do
		if data[i].type == "queue" then
			roleData = data[i].data
			break
		end
	end
	
	
	--自己一方人物头像
	local bgPath = IMG_PATH .. "image/scene/fb/"
	local roleImage = {}
	local addIndex = 0
	if roleData.p1 then
		for key , v in pairs(roleData.p1) do
			addIndex = addIndex + 1
			roleImage["s" .. addIndex ] = KNBtn:new( bgPath ,{"item_bg.png"} , 40 , 130 + addIndex * 80 , {front = getImageByType(v.cid , "s") }):getLayer()
			layer:addChild( roleImage["s" .. addIndex ] )
		end
	end
	if roleData.p1_back then
		for key , v in pairs(roleData.p1_back) do
			addIndex = addIndex + 1
			roleImage["s" .. addIndex ] = KNBtn:new( bgPath ,{"item_bg.png"} , addIndex > 6 and 130 or 40  , addIndex > 6 and ( 610 - ( addIndex - 7 ) * 80 ) or ( 130 + addIndex * 80 ) , {front = getImageByType(v.cid , "s") }):getLayer()
			layer:addChild( roleImage["s" .. addIndex ] )
		end
	end
	
	--敌方人物头像
	addIndex = 0
	if roleData.p2 then
		for key , v in pairs(roleData.p2) do
			addIndex = addIndex + 1
			roleImage["s" .. addIndex ] = KNBtn:new( bgPath ,{"item_bg.png"} , 360 ,  130 + addIndex * 80 , {front = getImageByType(v.cid or v.npc_id  , "s") }):getLayer()
			layer:addChild( roleImage["s" .. addIndex ] )
		end
	end
	
	if roleData.p2_back then
		for key , v in pairs(roleData.p2_back) do
			addIndex = addIndex + 1.
			roleImage["s" .. addIndex ] = KNBtn:new( bgPath ,{"item_bg.png"} , addIndex > 6 and 270 or 360 , addIndex > 6 and ( 610 - ( addIndex - 7 ) * 80 ) or ( 130 + addIndex * 80 ) , {front = getImageByType(v.cid or v.npc_id , "s") }):getLayer()
			layer:addChild( roleImage["s" .. addIndex ] )
		end
	end
	
	
	
	
	local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
	mask = KNMask:new( { item = layer } )
	
	local Scene = display.getRunningScene()
	Scene:addChild( mask:getLayer() )
end


return M
