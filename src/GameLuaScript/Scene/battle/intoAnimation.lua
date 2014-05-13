--[[

		入场动画

]]--

local skipLayer = requires(IMG_PATH,"GameLuaScript/Scene/battle/skipLayer")
local M = {}
--转动划开动画
function M:create( param )
	local PATH = IMG_PATH .. "image/scene/admission/"
	
	skipLayer:setIsDisabled( true ) --禁止跳过
	
	local layer = display.newLayer()
	
	
	local bg = display.newSprite( PATH .. "bg.png" )
    layer:addChild( bg )
    setAnchPos( bg , display.cx , display.cy  , 0.5 , 0.5 )
    
    local tray = display.newSprite( PATH .. "tray.png" )
    layer:addChild( tray )
    setAnchPos( tray , display.cx , display.cy - 10  , 0.5 , 0.5 )
    tray:runAction(CCRepeatForever:create(CCRotateBy:create(5,20)))
    
    
    local vsSp = display.newSprite( PATH .. "vs.png" )
    layer:addChild( vsSp )
    setAnchPos( vsSp , display.cx , display.cy , 0.5 , 0.5 )
    
   
	
	vsSp:setScale(3)
	transition.scaleTo(vsSp, {
		time = 1,
		scale = 1,
		easing = "ELASTICOUT",
		onComplete = function()
			param.animationOverCallFun()
			skipLayer:setIsDisabled( false ) --禁止跳过
			layer:removeFromParentAndCleanup(true)
		end
	})
	
	
    local text = display.strokeLabel( "请在网络畅通的地方使用，以获得最佳的战斗效果", 20, 40, 20 , ccc3( 0xff , 0xfb , 0xd4 ) , nil , nil )
	layer:addChild( text )
	return layer
end
--人物跑动进场动画
function M:create2( param )
	--动画效果
	local totalActionTime = 3 --动画时间

	param.animationOverCallFun = param.animationOverCallFun or function() end
	param.showInfo = param.showInfo or ""		--提示文字

	local layer = display.newLayer()


	local imagePath = IMG_PATH .. "image/scene/battle/"	--资源路径



	--读取所需数据
	local index = 0;
	local data = DATA_Battle:get("report")["1"]
	local function findQueue()

		if data[ index ] ~= nil then
			return nil
		end

		index = index + 1

		if data[ index ].type == "queue" and index ~= nil then
			data = data[ index ]
			index = nil
			return data
		else
			findQueue()
		end

	end
	data = findQueue()[ "data" ]

	local heroCell = requires(IMG_PATH,"GameLuaScript/Scene/battle/heroCell")
	local heros ={}	--己方英雄
	local foes = {}	--敌方人员处理
	local isAction = true

	local textInfo = nil 	--展示文本
---------------------------------------------------------------------------------------------
--
--	动画背景
--
	local animationBg = display.newSprite(imagePath .. "into_animation_bg.jpg")
	local size = animationBg:getContentSize()
	display.align( animationBg , display.TOP_LEFT , 0 , size.height )
	layer:addChild( animationBg )
	--进场动画展示完毕调用
	local function clearSelf()
		--清除当前界面所有动画
		CCDirector:sharedDirector():getActionManager():removeAllActions()
		isAction = false

		--初始化位置
		for i = 1 , #heros do
			heros[i]:setPosition( 12 + (i - 1) * 116 , 216 )
		end

		local handle
		handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
			handle = nil

			for i = 1 , #heros do
				heros[i].actionsBackFun = nil
				heros[i].actions = nil
				heros[i].actionNum = nil
				heros[i]:removeFromParentAndCleanup(true)	-- 清除自己
				heros[i] = nil

				foes[i] = nil	--清除敌方人员
			end
			heros = nil

			textInfo:removeFromParentAndCleanup(true)	-- 清除容器
			textInfo = nil

			layer:removeFromParentAndCleanup(true)	-- 清除容器
		end , 1 , false)


		-- 展示其它界面
		local handle2
		handle2 = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle2)
			handle2 = nil

			param.animationOverCallFun()
		end , 0.8 , false)
	end


	--背景图动画
	local action1 = transition.moveTo( animationBg , { time = totalActionTime , x = 0 , y = display.height , onComplete = clearSelf })

	for i = 1 , #data.p2 do
		foes[i] = heroCell.new( data.p2[i] )
		foes[i]:setAnchorPoint( ccp( 0.5 , 0.5 ) )
		foes[i]:setPosition( 12 + (i - 1) * 116 , size.height - (display.height - 493) )

		animationBg:addChild( foes[i] )
	end


-----------------------------------------------------------------------------
-----
--  自方人物处理
--
	--查找Queue数据

	index = 0
	--英雄动画设置
	local function createActions( target )
		local actions = CCArray:create()
		local time = 0.3
		--跳动
		local tx, ty = target:getPosition()
		actions:addObject( CCJumpTo:create( time , ccp(tx, ty) , 20 , 1) )

		--缩放控制
		local actionScales = CCArray:create()
		actionScales:addObject( CCScaleTo:create( time/2 , 1.05 ) )
		actionScales:addObject( CCScaleTo:create( time/2 , 1 ) )
		actionScales:addObject( CCCallFunc:create( function()
														target.actionNum = target.actionNum+1
														target.actionsBackFun()
													end ) )

		actions:addObject( CCSequence:create( actionScales ) )

		return actions
	end

	--创建己方英雄
	for i = 1 , #data.p1 do
		heros[i] = heroCell.new( data.p1[i] )
		heros[i]:setAnchorPoint( ccp( 0.5 , 0.5 ) )
		heros[i]:setPosition( 12 + (i - 1) * 116 , 216 )

		--自身动画
		heros[i].actionsBackFun = function () end
		heros[i].actions = createActions( heros[i] )
		heros[i].actionNum = 0	--动画计数器


		layer:addChild( heros[i] )
	end





---------------------------------------------------------------------------------------------------------------------
--
--    英雄动作处理
--
	local function run( target )
		target:runAction(  CCSpawn:create( createActions( target ) ) )
	end
	--英雄行走动画
	for i = 1 , #heros do
		heros[i].actionsBackFun = function()
			local handle
			handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
				handle = nil

				if isAction then
					run( heros[i] )
				end

			end , math.random(90, 110)/1000 , false)
		end

		-- 触发定时器
		local handle
		handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
			handle = nil

			if isAction then
				run( heros[i] )
			end
		end , math.random(100, 150)/1000 * (i - 1) , false)
	end


-----------------------------------------------------------------------------------------
--
--		展示的文字
--

	textInfo = CCLabelTTF:create(param.showInfo,"Verdana",20)
	textInfo:setPosition( ccp( display.cx , display.cy + 20 ) )
	textInfo:setColor(ccc3(0,0,0))
	layer:addChild(textInfo)

	return layer
end

return M
