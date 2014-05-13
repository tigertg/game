local PATH = IMG_PATH.."image/scene/home/"
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")--require "GameLuaScript/Common/KNBtn"
local HomeCard = requires(IMG_PATH,"GameLuaScript/Scene/home/homecard")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
--[[
	首页
]]
local HomeLayer= {
	layer,
	strengthItemLayer ,    --强化按钮所在层，控制强化的子项是否显示
	formationLayer,
	btnLayer,
	cardItems,    --英雄卡片元素
	allow,  --允许进行卡片移动的判断
	move,
}
local aideBtn
function HomeLayer:new()
	local this = {}
	setmetatable(this , self)
	self.__index = self
	
	this.layer = display.newLayer()
	this.allow = true
	local bg = display.newSprite(PATH .. "main.png")
	setAnchPos(bg , 0 , 0)
	this.layer:addChild(bg)
	
	bg = display.newSprite(PATH.."cloud.png")
	setAnchPos(bg,240, 70, 0.5)
	this.layer:addChild(bg)
	
	local lightBg = display.newSprite(PATH.."light_bg.png")
	setAnchPos(lightBg,245,90,0.5,0.5)
	this.layer:addChild(lightBg)
	
	lightBg:runAction(CCRepeatForever:create(CCRotateBy:create(5,20)))
	
	local light_front = display.newSprite(PATH.."light_front.png")
	setAnchPos(light_front,245,90,0.5,0)
	this.layer:addChild(light_front)
	
	this:createformation()
	
	--主页图标按钮初始化
	local function initBtn()
		if this.btnLayer then
			this.layer:removeChild(this.btnLayer , true)
		end

		this.btnLayer = display.newLayer()


		local guide_step = KNGuide:getStep()


		local light = display.newSprite(PATH.."btn_light.png")
		-- 副本按钮
		local btn_images = {"fb.png" , "fb_press.png"}
		if checkOpened("fb_equip") ~= true then btn_images = {"fb_disable.png"} end
		local temp = KNBtn:new(PATH , btn_images , 107 , 210 , {
			callback = function()
				-- 判断等级开放
				local check_result = checkOpened("fb_equip")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end

				local fb_type = "equip"
				if guide_step == 800 then fb_type = "equip"
				elseif guide_step == 3000 then fb_type = "hero"
				elseif guide_step == 3100 then fb_type = "pet"
				elseif guide_step == 3200 then fb_type = "skill"
				end

				switchScene("fb" , {coming = fb_type})
			end
		})
		setAnchPos(light, 107 + temp:getWidth() / 2, 210 + temp:getWidth() / 2,0.5,0.5)
		this.btnLayer:addChild(light)
		
		local function createAction()
			local action
			action = getSequenceAction(CCScaleTo:create(1,0.8),CCScaleTo:create(1,1),CCCallFunc:create(
			function()
				light:runAction(createAction())
			end))	
			return action
		end
		light:runAction(createAction())	
		this.btnLayer:addChild(temp:getLayer())

		-- 新手引导
		if guide_step == 800 or guide_step == 3000 or guide_step == 3100 or guide_step == 3200 then KNGuide:show( temp:getLayer() ) end



		
		-- 竞技按钮
		local btn_images = {"compete.png" , "compete_press.png"}
		if checkOpened("athletics") ~= true then btn_images = {"compete_disable.png"} end
		local temp = KNBtn:new(PATH , btn_images , 355 , 100 , {
			callback = function()
				-- 判断等级开放
				local check_result = checkOpened("athletics")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end

				local fb_type = "equip"
				if guide_step == 3300 then pvp_type = "rob"
				end
				switchScene("pvp" , {coming = pvp_type})
				
--
--
--				HTTP:call("athletics","get",{},{success_callback = 
--				function(data)
--					switchScene("athletics",{data = data })	
--				end})
			end
		})
		this.btnLayer:addChild(temp:getLayer())

		-- 新手引导
		if guide_step == 1300 or guide_step == 3300 then KNGuide:show( temp:getLayer() ) end


		-- 出战按钮
		local btn_images = {"mission.png" , "mission_press.png"}
		local temp = KNBtn:new(PATH , btn_images , 190 , 110 , {
			callback = function()
				DATA_Mission:setByKey("current","map_id",DATA_Mission:get("max","map_id"))
				DATA_Mission:setByKey("current","mission_id",DATA_Mission:get("max","mission_id"))
--				if DATA_Mission:haveData(DATA_Mission:get("max","map_id")) then
--					switchScene("mission")
--				else
					HTTP:call("mission" , "get",{},{success_callback = function()
						switchScene("mission")
					end })
--				end
			end
		})
		this.btnLayer:addChild(temp:getLayer())
		
		local aniMask = WindowLayer:createWindow()
		aniMask:setContentSize(CCSizeMake(temp:getWidth() - 25, temp:getHeight() - 25))
		setAnchPos(aniMask, 202, 124)
		this.btnLayer:addChild(aniMask)
		
		local moveLight = display.newSprite(COMMONPATH.."move_light.png")
		setAnchPos(moveLight, -moveLight:getContentSize().width)
		aniMask:addChild(moveLight)
		
		local function moveFun()
			local action
			action = getSequenceAction(CCMoveTo:create(1, ccp(temp:getWidth(), 0)), CCDelayTime:create(2),CCCallFunc:create(function()
				setAnchPos(moveLight, -moveLight:getContentSize().width)
				moveLight:runAction(moveFun())
			end))	
			return action	
		end
		moveLight:runAction(moveFun())
			

		-- 新手引导
		if guide_step == 101 or guide_step == 209 or guide_step == 304 or guide_step == 505 or guide_step == 704 then KNGuide:show( temp:getLayer() ) end


		-- 礼包按钮
		local btn_images = {"gift.png"}
		local temp = KNBtn:new(PATH , btn_images , 10 , 255 , {
			other = DATA_Notice:getGetNum() > 0  and { COMMONPATH .. "egg_num_bg.png" , 60 , 60  } or nil,
			text = DATA_Notice:getGetNum() > 0 and { 1 , 16 , ccc3( 0xff , 0xff , 0xff ) , { x = 32 , y = 31 } , nil , 17 }   or nil ,  
			callback = function()
--				HTTP:call("achievegift", "get", {},{success_callback = 
--				function()
--					local activityLayer = requires(IMG_PATH, "GameLuaScript/Scene/common/activity")
--					display.getRunningScene():addChild( activityLayer:new():getLayer() )
--				end})

				--活动
				HTTP:call("activity" , "get", {} , {
					success_callback = function()
						switchScene("activity")
					end
				})
				
				--在线礼包
--				local onlineLayer = requires(IMG_PATH, "GameLuaScript/Scene/common/onlinegift")
--				display.getRunningScene():addChild( onlineLayer:new():getLayer() )
			end
		})
		this.btnLayer:addChild(temp:getLayer())


		
		-- 打造按钮
		local btn_images = {"activity.png" , "activity_press.png"}
		if checkOpened("forge") ~= true then btn_images = {"activity_grey.png"} end
		local temp = KNBtn:new(PATH , btn_images , 270 , 210 , {
			callback = function()
				-- 判断等级开放
				local check_result = checkOpened("forge")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end

				switchScene("forge")
			end
		})
		temp:setEnable(true)
		this.btnLayer:addChild(temp:getLayer())

		-- 新手引导
		if guide_step == 1500 or guide_step == 1509 or guide_step == 3400 then KNGuide:show( temp:getLayer() ) end


		-- 宠物按钮
		local btn_images = {"pet.png" , "pet_press.png"}
		if checkOpened("pet") ~= true then btn_images = {"pet_disable.png"} end
		local temp = KNBtn:new(PATH , btn_images , 35 , 100 , {
			callback = function()
				-- 判断等级开放
				local check_result = checkOpened("pet")
				if check_result ~= true then
					KNMsg:getInstance():flashShow(check_result)
					return
				end

				switchScene("pet")
			end
		})
		this.btnLayer:addChild(temp:getLayer())

		this.layer:addChild(this.btnLayer)

		-- 新手引导
		if guide_step == 400 or guide_step == 500 or guide_step == 1200 then KNGuide:show( temp:getLayer() ) end
	end

	initBtn()


	-- 进场的引导
	if KNGuide:getStep() == 100 then
		KNGuide:show( nil , {
			mask_clickable = true,
			callback = function()
				initBtn()
			end,
			x = -100,
			y = 300,
			width = 1,
			height = 1,
		})
	end


	--聊天入口
	local btn_images = {"aide.png" , "aide_press.png"}
	local curTalk
	if checkOpened("talk") ~= true then btn_images = {"aide_press.png"} end
	local temp = KNBtn:new( IMG_PATH .. "image/scene/chat/"  , {"talk_flag1.png"} , 380 , 240 , {
		priority = -150,
		scale = true ,
		front = IMG_PATH .. "image/scene/chat/talk_flag.png" , 
		callback = function()
			local tempType = DATA_Info:getSourceType()
			DATA_Info:setIsMsg( false )
			if DATA_Info:getIsOpen( ) then
				local talkLayer = requires(IMG_PATH,"GameLuaScript/Scene/common/talk")
				curTalk = talkLayer:new( { type = tempType } )
				local curScene = display.getRunningScene()
				curScene:addChild( curTalk:getLayer()  )
			else
				curTalk:remove()
			end
			DATA_Info:setIsOpen( not DATA_Info:getIsOpen( ) )
		end
	})
	this.btnLayer:addChild(temp:getLayer())
	DATA_Info:addActionBtn( "home" , temp )
	
	if CHANNEL_ID == "tmsjIosAppStore" then
		temp:getLayer():setVisible( false )
		temp:setEnable(false)
	end
	
--	local gangSp = display.newSprite( IMG_PATH .. "image/scene/chat/talk_flag2.png" , temp:getLayer():getContentSize().width/2 , temp:getLayer():getContentSize().height/2 , 0.5 , 0.5 )
--	gangSp:setVisible(false)
--	temp:getLayer():addChild( gangSp , 5 )
--	
--	local worldSp = display.newSprite( IMG_PATH .. "image/scene/chat/talk_flag3.png" , temp:getLayer():getContentSize().width/2 , temp:getLayer():getContentSize().height/2 , 0.5 , 0.5 )
--	worldSp:setVisible(false)
--	temp:getLayer():addChild( worldSp , 6 )
--	
--	DATA_Info:addActionBtn( "home" , { btn = temp , gang = gangSp , world = worldSp } )
	-- 小助手按钮
	local cur_mission_step = DATA_Guide:get()
	if KNGuide:getStep() == 4200 or
	   (
			(cur_mission_step["map_id"] > 2  or (cur_mission_step["map_id"] == 2  and cur_mission_step["mission_id"] >= 6) ) and
			(cur_mission_step["map_id"] < 11 or (cur_mission_step["map_id"] == 11 and cur_mission_step["mission_id"] < 5) )
		)
	then
		aideBtn = KNBtn:new(PATH , {"aide.png" } , 15 , 610 , {
			scale = true ,
			callback = function()
				if KNGuide:getStep() == 4201 then
					self:aideAction()
				else
					self:createAide()
				end
			end
		}):getLayer()
		this.btnLayer:addChild( aideBtn )
		
		local light = display.newSprite(PATH.."aide_light.png")
		
		local function createAction()
			local action
			action = getSequenceAction(CCScaleTo:create(1,0.8),CCScaleTo:create(1,1),CCCallFunc:create(
			function()
				light:runAction(createAction())
			end))	
			return action
		end
		light:runAction(createAction())	
		setAnchPos( light , temp:getWidth() / 2, temp:getWidth() / 2 , 0.5 , 0.5 )
		aideBtn:addChild( light )
		
		if KNGuide:getStep() == 4100 or KNGuide:getStep() == 4200 then
			KNGuide:show( aideBtn , {remove = true})
		end
	end
	
    return this.layer
end
function HomeLayer:aideAction()
    local actionAry = CCArray:create()
    actionAry:addObject( CCCallFunc:create( 
						function()
							if aideBtn then
								aideBtn:removeFromParentAndCleanup( true ) 
								aideBtn = nil
							end
						 	aideBtn = KNBtn:new(PATH , {"aide.png" , "aide_press.png"} , 15 , 620 , {
								callback = function()
									self:createAide()
								end
							}):getLayer()
							
							--打开设置界面
							local infoLayer = requires(IMG_PATH, "GameLuaScript/Scene/common/infolayer")
							infoLayer:showMoreBtn()
							
							local SettingLayer = requires(IMG_PATH, "GameLuaScript/Scene/common/setting")
							display.getRunningScene():addChild( SettingLayer:new():getLayer() )
							
							display.getRunningScene():addChild( aideBtn , 10 )
						 end ) )
    
    actionAry:addObject( CCCallFunc:create(
    					function()
							transition.moveTo( aideBtn , { time = 0.5 , x = 50 , y = 350 , onComplete = 
							function() 
								if aideBtn then
									aideBtn:removeFromParentAndCleanup( true ) 
									aideBtn = nil
								end
							end } )
    					end ))
    actionAry:addObject( CCCallFunc:create( 
						function()
    						aideBtn:removeFromParentAndCleanup( true ) 
							aideBtn = nil 
						end ) )
   aideBtn:runAction( CCSequence:create( actionAry ) )
end

function HomeLayer:basePopup( titlePath )
	local bg = display.newSprite( IMG_PATH .. "image/scene/mission/wipe_bg.png")
	local addX = 90
	local addY = 324
	
	local titleBg = display.newSprite( IMG_PATH .. "image/scene/mission/title_bg.png")
	setAnchPos(titleBg, addX , addY)
	bg:addChild(titleBg)
	
	local title = display.newSprite( titlePath )
	setAnchPos(title, addX - 24 , addY )
	bg:addChild(title)
	
	return bg
end

--小助手配置
function HomeLayer:createAide( params )
	params = params or {}
	local layer = display.newLayer()
	local mask
	local AIDEPATH = IMG_PATH .. "image/scene/aide/"
	
	local bg = self:basePopup( AIDEPATH .. "title.png" )
	setAnchPos( bg , display.cx , display.cy + 30 , 0.5 , 0.5 )
	layer:addChild(bg)
	local configElement = { "exp" , "hero" , "equip" , "silver" }
	
	if checkOpened("pet") == true then
		configElement[ #configElement + 1 ] = "pet"
	end	
	if checkOpened("skill") == true then
		configElement[ #configElement + 1 ] = "skill"
	end
	for i = 1 ,#configElement do
		local addX , addY = 79 +  ( ( i - 1 ) % 2 ) * 179 , 486 - math.floor(( i - 1 )/2) * 74
		local tempBtn = KNBtn:new( COMMONPATH , { "btn_bg_red.png" , "btn_bg_red_pre.png" , "btn_bg_red2.png" }, 
			addX , addY ,
			{
				front = AIDEPATH .. "need_" .. configElement[i] .. ".png" ,
				priority = -142,	
				callback=
				function()
					switchScene( "aide" , { type = configElement[i] , backFun = function() switchScene( "home" , nil , function() self:createAide() end ) end} )
				end
			})
		layer:addChild( tempBtn:getLayer() )
	end
	
	--返回按钮
	local cancelBtn = KNBtn:new(COMMONPATH,{"back_img.png","back_img_press.png"},35,573,{
		scale = true,
		priority = -142,	
		callback = function()
			mask:remove()
		end
	})
	layer:addChild(cancelBtn:getLayer())
	
	setAnchPos( layer , -display.width , 0 )
	transition.moveTo( layer , {time = 0.5 , easing = "BACKOUT" , x = 0 })
	local scene = display.getRunningScene()
	mask = KNMask:new({ item = layer , priority = -141 })
	scene:addChild( mask:getLayer() )
end

function HomeLayer:createformation()
	self.formationLayer = display.newLayer()
	self.formationLayer:setTouchEnabled(true)
	self.cardItems = {}
	
	local bg = display.newSprite(PATH.."formation_view_bg.png")
	setAnchPos(bg)
	self.formationLayer:addChild(bg)
	
	self.formationLayer:setContentSize(bg:getContentSize())
	setAnchPos(self.formationLayer , 10 , 345)

	-- 新手引导
	local guide_step = KNGuide:getStep()
	if guide_step == 200 or guide_step == 300 or guide_step == 700 or guide_step == 1100 or guide_step == 2500 or guide_step == 4000 then KNGuide:show( self.formationLayer , {height = 275} ) end
	
	local title = display.newSprite(PATH.."my_formation.png")
	setAnchPos(title,bg:getContentSize().width / 2,bg:getContentSize().height - 50,0.5)
	self.formationLayer:addChild(title)
	
	--生成主页滑动卡牌
	for i = 1, 8 do
		self.cardItems[i] = HomeCard:new(135 , i , i > DATA_Formation:get_lenght())
		self.cardItems[i]:addTo(i,self.formationLayer)
	end
	
	--默认将第一个武将显示在最前方
	for k, v in pairs(self.cardItems) do
		v:setState(2,self)
	end
	
	if DATA_Formation:get_lenght() > 0 then
		DATA_Formation:setCur(DATA_Formation:get_index(1)["gid"])
	end
			
	local touchX, legal,lastX,time,speed
	self.formationLayer:registerScriptTouchHandler(function(type,x,y)
		--不在范围内直接跳过
		if not CCRectMake(10,330,bg:getContentSize().width,
				bg:getContentSize().height):containsPoint(ccp(x,y)) then
			return false
		end
		if type == CCTOUCHBEGAN then
			touchX = x
			lastX = x
			legal = true
			time = os.clock()
		elseif type == CCTOUCHMOVED then
			local dir = x < lastX
			
			if math.abs(touchX - x) > 10 then
				touchX = x
				speed = os.clock() - time
				time = os.clock()
				if self.allow then
					self.move = true
					self.allow = false
					--下面是不进行循环移动的判断
--					if dir then
--						if self.cardItems[1].pos > -(#self.cardItems - 4) then
--							self.move = true
--							self.allow = false
--						end
--					else
--						if self.cardItems[1].pos < 3 then
--							self.move = true
--							self.allow = false
--						end
--					end
				end
				legal = false		
			end
			
			if self.move then
				self.move = false
				for i = 1, #self.cardItems do
					self.cardItems[i]:move(dir,self,speed)
				end
			end
			lastX = x
		else
			if legal and DATA_Formation:getCur() then
				if DATA_General:haveGet() then
					DATA_Formation:set_index(1)
					switchScene("hero",{gid = DATA_Formation:getCur()})
				else
					HTTP:call("general" , "get",{},{success_callback =
						function()
							DATA_General:haveGet(true)
							DATA_Formation:set_index(1)
							switchScene("hero",{gid = DATA_Formation:getCur() })
						end
					})
				end
			end
			touchX = 0
			lastX = 0
			legal = false	
		end
		return true
	end,false,0,false)
	
	self.layer:addChild(self.formationLayer)
end

return HomeLayer
