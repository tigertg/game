-- 全局变量
GLOBAL_INFOLAYER = nil




local PATH = IMG_PATH .. "image/scene/common/"

--[[
	用户信息及底部控制按钮层，可以由其他场景直接添加，创建时须要提供对应的layerName并以此来设置底部按钮的选中状态
    layerName取值｛首页：home , 背包:bag , 酒馆:tavern，消息：msg , 商城:shop , 设置:setting｝
    可以使用showInfo函数来设定是否显示用户信息栏
]]
local KNBar = requires(IMG_PATH , "GameLuaScript/Common/KNBar")
local KNRadioGroup = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local SelectList = requires(IMG_PATH,"GameLuaScript/Scene/common/selectlist")
local InfoLayer = {
	userInfoLayer,  --用户信息
	navigationLayer, -- 导航栏
	msgLayer,          --聊天信息栏
	layer,      --功能层
	chooseBtn,   --当前选中的按钮项
	title,
	back_btn,
	view_type,
}
local scroll

function InfoLayer:new(layerName , view_type , params)
	local this = {}
	setmetatable(this , self)
	self.__index = self


	this.params = params or {} 
	if view_type == nil then view_type = 1 end
	this.view_type = view_type
	this.msgText = nil

	-- 首页的元素拆分开
	this.layer = display.newLayer()
	this.layer:setTag(8888)
	GLOBAL_INFOLAYER = this

	--隐藏信息背景
	if not this.params["title_hide"] then	
		this.title = display.newSprite(PATH .. "title_" .. view_type .. ".png")
		setAnchPos(this.title , 0 , display.height - this.title:getContentSize().height)
		this.layer:addChild( this.title )	
		
		if view_type == 0 then
			this.back_btn = KNBtn:new(COMMONPATH, {"back_img.png" , "back_img_press.png"} , 50 , 765 , {
				priority = this.params.priority,
				callback = this.params.closeCallback or function()
					switchScene("home")
				end
			})
			this.layer:addChild(this.back_btn:getLayer())
			
			if not this.params["tail_hide"] then
				local tail =  display.newSprite(COMMONPATH.."title_tail.png")
				setAnchPos(tail , 0 , display.height - this.title:getContentSize().height * 1.45)
				this.layer:addChild( tail )	
			end
		end
	end
	

	--标题 
	if this.params["title_text"] then
		this.name = nil
		if type(this.params["title_text"]) == "string" then	
			 this.name = display.newSprite(this.params["title_text"])
		else
			this.name = this.params["title_text"]
		end
		setAnchPos( this.name , 240 , display.height - this.title:getContentSize().height / 2 + 4 , 0.5 , 0.7 )
		this.layer:addChild( this.name )		
	end
	
	
	if view_type > 1 then
		this:refreshInfo()
	end

	-- initMsg()
	this:refreshMsg()
	this:refreshBtn(layerName)

	
    return this
end
--刷新标题
function InfoLayer:refreshTitle( path )
	if self.name then
		self.name:removeFromParentAndCleanup( true )
		self.name = nil
	end
	
	self.name = display.newSprite( path )
	setAnchPos( self.name , 240 , display.height - self.title:getContentSize().height / 2 + 4 , 0.5 , 0.7 )
	self.layer:addChild( self.name )	
end

function InfoLayer:getLayer()
	return self.layer
end

function InfoLayer:update(type)
	if self.layer then
		if not type then
			self:refreshMsg()
			self:refreshInfo()
		end

		if type == "msg" then
			self:refreshMsg()
		end

		if type == "info" then
			self:refreshInfo()
		end
	end
end


function InfoLayer:refreshBtn(layerName)
	self.navigationLayer = display.newLayer()

	if not layerName or layerName ~= "home" then
		local bottom_black = display.newSprite(PATH .. "bottom_black.png")
		setAnchPos(bottom_black , 0 , 0)
		self.navigationLayer:addChild(bottom_black)
	end

	local bottom = display.newSprite(PATH .. "bottom.png")
	setAnchPos(bottom , 0 , -7)
	self.navigationLayer:addChild(bottom)

	local optionY = 0
	local initX = 25
	local spaceX = 87
	
	--首页底部的按钮信息
	local guide_step = KNGuide:getStep()
	local btnInfo = {
	{ --首页
		"home" , 
		initX , 
		optionY , 
		{"na_home.png" , "na_home_pre.png"},
		function()
			switchScene("home")
		end
	} , 
	{ --背包
		"bag" , 
		initX + spaceX , 
		optionY , 
		{"na_bag.png" , "na_bag_pre.png"},
		function()
--				if DATA_Bag:haveData("equip") then
--					switchScene("bag")	
--				else
--					HTTP:call("bag","get",{type = "equip"},{success_callback=
--					function()
--					end})
--				end
			switchScene("bag")	
		end
	} ,
	{ -- 
		"ranklist" , 
		initX + spaceX * 2 , 
		optionY , 
		{"na_ranklist.png" , "na_ranklist_pre.png"},
		function()
			switchScene("ranklist","level")
		end
	} , 
	{ -- 商城
		"shop" , 
		initX + spaceX * 3 , 
		optionY , 
		{"na_shop.png" , "na_shop_pre.png"},
		function()
			if DATA_Shop:haveData() then
				switchScene("shop")
			else
				HTTP:call("shop","get",{},{success_callback=
					function()
						switchScene("shop")
					end
				})
			end
		end
	} , 
	{ -- 帮会
		"gang" , 
		initX + spaceX * 3 , 
		optionY , 
		{"gang.png" , "gang_press.png"},
		function()
			local check_result = checkOpened("gang")
			if check_result ~= true then
				KNMsg:getInstance():flashShow(check_result)
				return
			end

			--帮派
			HTTP:call("alliance", "get", {},{success_callback = 
			function()
				switchScene("gang")
			end})
		end
	} , 
	{ --好友
		"friend" , 
		initX , 
		optionY , 
		{"friend.png" , "friend_pre.png"},
		function()
			local check_result = checkOpened("friend")
			if check_result ~= true then
				KNMsg:getInstance():flashShow(check_result)
				return
			end

			HTTP:call("friends","get",{},{success_callback=
			function()
				switchScene("friend")
			end})
		end
	} , 
	{ --设置
		"setting" , 
		initX + spaceX * 4 , 
		optionY , 
		{"na_setting.png" , "na_setting_pre.png"},
		function()
			local SettingLayer = requires(IMG_PATH, "GameLuaScript/Scene/common/setting")
			display.getRunningScene():addChild( SettingLayer:new():getLayer() )
		end
	}}

	local temp, select 
--	{ }
	local btn_names = {}
	scroll = KNScrollView:new( 30 , 0 , 420 , 83 , 5 , true , nil , { turnBtn = IMG_PATH .. "image/scene/gang/next.png", priority = self.params.priority and self.params.priority - 1 or nil } )
	for i , v in pairs(btnInfo) do
		temp = KNBtn:new(PATH .. "navigation", v[4] , 0 , 0 , {
			parent = scroll ,
--			upSelect = true , 
			frontZOrder = -10 , 
			priority = self.params.priority,
			front = PATH .. "btn_bg.png" , 
			callback = function() 
				if v[1] == "gang" then
					v[5]()
				else
					if display.getRunningScene()["name"] ~= v[1] then
						v[5]()
					end
				end
			end,
			scale = true ,
		})

		scroll:addChild( temp:getLayer(), temp )

		btn_names[v[1]] = i
	end
	scroll:alignCenter()
	self.navigationLayer:addChild(scroll:getLayer() )
	

	self.layer:addChild(self.navigationLayer)


	local guide_btn = nil
	if guide_step == 2000 then
		guide_btn = "bag"
	elseif guide_step == 208 or guide_step == 303 or guide_step == 504 or guide_step == 703 or guide_step == 1508 then
		guide_btn = "home"
	elseif guide_step == 3500 then
		guide_btn = "gang"
	elseif guide_step == 3600 then
		guide_btn = "friend"
	end

	if guide_btn ~= nil then
		if btn_names[guide_btn] > 3 then
			scroll:setIndex(btn_names[guide_btn] , true)
		end

		local temp = scroll:getItems( btn_names[guide_btn] )
		local btn_range = temp:getRange()
		KNGuide:show( temp:getLayer() , {
			x = btn_range:getMinX(),
			y = btn_range:getMinY(),
		})
	end
		--[[
	if v[1] == "bag" then
		-- 新手引导
		
			local btn_range = temp:getRange()
			KNGuide:show( temp:getLayer() , {
				x = btn_range:getMinX(),
				y = btn_range:getMinY(),
			})
		end
	elseif v[1] == "home" then
		-- 新手引导
		if guide_step == 208 or guide_step == 303 or guide_step == 504 or guide_step == 703 or guide_step == 1508 then
			local btn_range = temp:getRange()
			KNGuide:show( temp:getLayer() , {
				x = btn_range:getMinX(),
				y = btn_range:getMinY(),
			})
		end
	elseif v[1] == "gang" then
		-- 新手引导
		if guide_step == 3500 then
			local btn_range = temp:getRange()
			KNGuide:show( temp:getLayer() , {
				x = btn_range:getMinX(),
				y = btn_range:getMinY(),
			})
		end
	elseif v[1] == "friend" then
		-- 新手引导
		if guide_step == 3600 then
			local btn_range = temp:getRange()
			KNGuide:show( temp:getLayer() , {
				x = btn_range:getMinX(),
				y = btn_range:getMinY(),
			})
		end
	end
	]]
	
end
--只用于小助手动画中
function InfoLayer:showMoreBtn()
	scroll:setIndex( 4 , true )
end

function InfoLayer:refreshInfo()
	if self.userInfoLayer then
		self.layer:removeChild(self.userInfoLayer,true)
	end
	self.userInfoLayer = display.newLayer()


	if self.view_type == 3 then
--		self.userInfoLayer:addChild( KNBar:new("power" , 120 , 150 , { maxValue = DATA_Power:get("max") , curValue = DATA_Power:get("num"), color = ccc3(255, 255, 255) }))
		self.userInfoLayer:addChild( display.strokeLabel( DATA_Power:get("num") .. "/" .. DATA_Power:get("max")  , 110 , 694 , 18 , ccc3( 0x93 , 0xfa , 0x31 ) ) )
		self.userInfoLayer:addChild( display.strokeLabel(DATA_Formation:countLead() .. "/" .. DATA_User:getLead()  , 265 , 694 , 18 , ccc3( 0x93 , 0xfa , 0x31 ) ) )
		self.userInfoLayer:addChild( display.newSprite( SCENECOMMON .. "lead_text.png" , 220 , 693 , 0 , 0 ) )
				
		self.userInfoLayer:addChild( KNBar:new("home_exp" , 80 , 105 , { maxValue = DATA_User:get("lvup_exp") , curValue = DATA_User:get("cur_exp") }))
		
		local function leadFun()
			local layer = display.newLayer()
			
			layer:addChild( display.newSprite( IMG_PATH .. "image/scene/mission/wipe_bg.png" , display.cx , 277 , 0.5 , 0 ) ) 
			layer:addChild( display.newSprite( IMG_PATH .. "image/scene/userinfo/lead_bg.png" , display.cx , 335 , 0.5 , 0 ) ) 
			layer:addChild( display.strokeLabel("1.统帅力随玩家的等级提升自动增加" , 110 , 313 , 18 , ccc3(0x2c , 0x00 , 0x00) ) )
			layer:addChild( display.strokeLabel("2.上阵英雄需玩家的统帅力达到要求" , 110 , 293 , 18 , ccc3(0x2c , 0x00 , 0x00)) )
			
			local leadConfig = getConfig( "generallead" )
			for i = 1 , table.nums( leadConfig ) do
				layer:addChild( display.strokeLabel( leadConfig[i..""]["lead"] .. "点" , 340 , 495 - ( i - 1 ) * 38 , 20 , ccc3( 0xff , 0xfb , 0xd6 ) ) )
				for j = 1 , i do
					layer:addChild( display.newSprite( COMMONPATH .. "star.png" , ( 125 - i/2 * 30 ) + j * 30  , 490 - ( i - 1 ) * 37 , 0.5 , 0 ) )
				end
			end
			
			
			
			
			
			local mask = KNMask:new( { item = layer } )
			local colseBtn = KNBtn:new(IMG_PATH .. "image/scene/chat/",{"close.png","close_press.png"} , 418 , 600 ,{ scale = true,priority = -130,callback=
				function()
					mask:remove()
				end}):getLayer()
			layer:addChild( colseBtn )
			setAnchPos( layer , 0 , display.height )
			transition.moveTo(layer , {time = 0.5 , easing = "BACKOUT" , y = 0 })
			self.userInfoLayer:addChild( mask:getLayer() )
		end
		self.userInfoLayer:addChild(KNBtn:new(COMMONPATH, {"lead.png", "lead_pre.png"}, 336 , 692, {callback = leadFun } ):getLayer())
		
		self.userInfoLayer:addChild(KNBtn:new(COMMONPATH, {"add_small.png", "add_small_press.png"}, 180 , 692, {
			callback = function()
				if not DATA_Bag:getTypeNum("prop", "powerdrug") then
					KNMsg.getInstance():boxShow("您没有鸡血丸了，要去商城购买吗？", {cancelFun = function()end, confirmFun = function()
						HTTP:call("shop","get",{},{success_callback=
							function()
								switchScene("shop")
							end
						})
					end})
					return false
				end
				local list
				list = SelectList:new("prop",self.userInfoLayer,display.newSprite(COMMONPATH.."title/prop_text.png"),{ 
					btn_opt = "use.png",
					y = 85,
					showTitle = true , 
					filter = {type = "powerdrug"},
					optCallback = function()
						list:destroy()
						HTTP:call("status", "eat", {id = list:getCurItem():getId()},{success_callback=
							function()
								self:refreshInfo()
								KNMsg.getInstance():flashShow("使用成功，体力增加")
							end})
					end
				})
				self.layer:addChild(list:getLayer() , 11)
			end
		}):getLayer())


		-- logo
		self.userInfoLayer:addChild(KNBtn:new( COMMONPATH , {"sex".. DATA_User:get("sex") .. ".jpg"} , 29 , 733 , {
			front = COMMONPATH .."role_frame.png",
--			other = { IMG_PATH .. "image/scene/vip/vip_flag.png" , -15 , -10 } , 
			callback = function()
				HTTP:call("status" , "get" , {} , {
					success_callback = function(params)
						switchScene("userinfo",params)
					end
				})
			end
		}):getLayer())	
		self.userInfoLayer:addChild( display.newSprite(PATH .. "navigation/level_bg.png" , 33 , 795) )

		if DATA_Vip:isVip() then
			self.userInfoLayer:addChild( display.newSprite( IMG_PATH .. "image/scene/vip/v" .. DATA_Vip:get( "viplv" ) .. ".png" , 90 , 759  , 0 , 0 ) )
		end
		self.userInfoLayer:addChild( display.strokeLabel(DATA_User:get("name") , ( DATA_Vip:isVip() and 130 or 100 ) , 762 , 22 , ccc3(255 , 251 , 212) , 2 ) )

		local level_label = display.strokeLabel(DATA_User:get("lv") , 30 , 785 , 18 , ccc3(179 , 58 , 0) )
		setAnchPos(level_label , 32 , 785 , 0.5)
		self.userInfoLayer:addChild( level_label )


		self.userInfoLayer:addChild( display.newSprite(PATH .. "navigation/money_bg.png" , 325 , 782) )
		self.userInfoLayer:addChild( display.newSprite(PATH .. "navigation/money_bg.png" , 325 , 752) )
		self.userInfoLayer:addChild( display.newSprite(COMMONPATH.."gold.png" , 282 , 782) )
		self.userInfoLayer:addChild( display.newSprite(COMMONPATH.."silver.png" , 282 , 752) )
		
		local gold = DATA_Account:get("gold")
		local silver = DATA_Account:get("silver") 
		
		gold = gold > 100000 and math.floor(gold / 10000).."万" or gold
		silver = silver > 100000 and math.floor(silver / 10000).."万" or silver
		
		self.userInfoLayer:addChild( display.strokeLabel(gold, 305 , 771 , 18 , ccc3(255 , 251 , 212) , 2 ) )
		self.userInfoLayer:addChild( display.strokeLabel(silver, 305 , 741 , 18 , ccc3(255 , 251 , 212) , 2 ) )


		-- 充值按钮
		local charge_btn = KNBtn:new(PATH .. "navigation" , {"vip.png" , "vip_pre.png"} , 398 , 729 , {
			callback = function()
				HTTP:call("vip" , "get" , {} , {
					success_callback = function()
						switchScene("vip")
					end
				})
			end,
			scale = true,
		})
		self.userInfoLayer:addChild(charge_btn:getLayer())
	end
	self.layer:addChild(self.userInfoLayer)
end


function InfoLayer:refreshMsg()
		if self.msgLayer then
			self.layer:removeChild(self.msgLayer , true)
		end

		self.msgLayer = display.newLayer()

		-- 图片
		self.msgLayer:addChild( display.newSprite(PATH .. "navigation/na_msg.png" , 427 , 15) )


		local msg = "提示：账号及黄金买卖骗子多，请勿参与！"
		local last_msg = DATA_Chat:getLast()
		if last_msg ~= nil and last_msg ~= false and last_msg.templateno ~= 4 then
			msg = self:formatMsg(last_msg.template , last_msg.msg or {})
		end
		if device.platform == "ios" then
				self.msgLayer:addChild( display.strokeLabel( msg , 30 , 3 , 20 , ccc3(255 , 251 , 212) , nil , nil , {
					dimensions_width = 380,
					dimensions_height = 24,
					align = 0,
				}))
		else
			 local showWidth = 380	--可见宽度
			 self.msgText = display.strokeLabel( msg , 0 , 3 , 20 , ccc3(255 , 251 , 212) , nil , nil , {
			 	dimensions_width = 1500 ,
			 	dimensions_height = 24,
			 	align = 0,
			 })
	 		 local windowlayer = WindowLayer:createWindow()
			 windowlayer:setAnchorPoint( ccp(0 , 0 ) )
			 windowlayer:setPosition( 30 , 0 )
			 windowlayer:setContentSize( CCSizeMake( showWidth , 43 ) )
			 windowlayer:addChild( self.msgText )
			 self.msgLayer:addChild( windowlayer )
			
			--临时计算长
			local tempText = display.strokeLabel( msg , 0 , 3 , 20 , ccc3(255 , 251 , 212))
			local widthValue = tempText:getContentSize().width - showWidth
			local fall = 0		--初始位置
			local effectiveRange = 30	--有效延长距离
			local isForward = false	--是否是正方向
			local addOffX = 1		--单次移动像素
			local refreshTime = 0.01	--刷新时间
			local function rollText()
					if isForward then
						fall = fall + addOffX
						if fall >= effectiveRange then
							isForward = false
						end
					else
						fall = fall - addOffX
						if fall < -widthValue - effectiveRange then
							isForward = true
						end
					end
					if self.msgText then
						xpcall( function() setAnchPos( self.msgText , fall , 3 ) end , function() self.msgText = nil end)
					end
			end
			
			local handle
			
			if widthValue > 0 then
			 	handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc( rollText , refreshTime , false)
			else
			 	if handle then
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
			 	end
				handle = nil
			end
		    
		end
		
--		 local showWidth = 380	--可见宽度
--		 local msgText = display.strokeLabel( msg , 0 , 3 , 20 , ccc3(255 , 251 , 212) , nil , nil , {
--		 	dimensions_width = 0,
--		 	dimensions_height = 24,
--		 	align = 0,
--		 })
--		 local windowlayer = WindowLayer:createWindow()
--		 windowlayer:setAnchorPoint( ccp(0 , 0 ) )
--		 windowlayer:setPosition( 30 , 0 )
--		 windowlayer:setContentSize( CCSizeMake( showWidth , 43 ) )
--		 windowlayer:addChild( msgText )
--		 self.msgLayer:addChild( windowlayer )
--		
--		 local widthValue = msgText:getContentSize().width - showWidth
--		 local timeRate = widthValue / 100
--		 local isDouble = false	--是否是双次
--		 local function rollText( value )
--		 	local addX = isDouble and 0 or  -widthValue
--		 	isDouble = not isDouble
--		 	transition.moveTo( msgText , { x = addX , time = 3 + 3 * timeRate , onComplete = rollText })
--		 end
--		 if widthValue > 0 then
--		 	rollText( )
--		 end
		
		-- 提醒数字
		local msg_num = DATA_Chat:getNum()
		if msg_num > 0 then
			if msg_num > 20 then msg_num = 20 end

			self.msgLayer:addChild( display.newSprite(PATH .. "navigation/na_msg_num.png" , 443 , 10) )

			local msg_num_label = display.strokeLabel( msg_num , 444 , 0 , 16 , ccc3(255 , 255 , 255) )
			msg_num_label:setAnchPos( ccp(0.5 , 0 ) )
			self.msgLayer:addChild( msg_num_label )
		end

		
		if self.view_type == 3 or self.view_type == 5 then
			setAnchPos(self.msgLayer , 0 , display.height - 33 - 4)
		elseif self.view_type == 1 or self.view_type == 2 then
			setAnchPos(self.msgLayer , 0 , display.height - 45 - 4)
		else
			setAnchPos(self.msgLayer , 0 , display.height - 25 - 4)
		end
		self.layer:addChild(self.msgLayer , 10)


		-- 点击事件
		local touchRect = CCRectMake(0 , display.height - 35 , display.width , 35)
		self.msgLayer:addTouchEventListener(function(event , x , y)
			if event == CCTOUCHBEGAN then
				if not touchRect:containsPoint( ccp(x , y) ) then
					return false
				end

				return true
			elseif event == CCTOUCHMOVED then
				return true
			elseif event == CCTOUCHENDED then
				if not touchRect:containsPoint( ccp(x , y) ) then
					return false
				end

				local scene = display.getRunningScene()
				if scene.name ~= "chat" then
					HTTP:call("message" , "get" , {} , {
						success_callback = function()
							switchScene("chat")
						end
					})
				end
			end
			
			return false
		end)
		self.msgLayer:setTouchEnabled(true)
end

--是否显示信息栏
function InfoLayer:showInfo( title_type )
	if title_type == 1 then
		self.userInfoLayer:setVisible(false)
	else
		self.userInfoLayer:setVisible(true)
	end
	self.layer:removeChild(self.title,true)
	self.title = display.newSprite(PATH .. "title_" .. title_type .. ".png")
	setAnchPos(self.title , 0 , display.height - self.title:getContentSize().height)
	self.layer:addChild(self.title , -1)
end


function InfoLayer:formatMsg(str , replace)
	if not str then return "" end

	if type(replace) == "table" and table.nums(replace) > 0 then
		local nums = 0

		str = string.gsub(str , "#s#" , function()
			nums = nums + 1
			if replace[nums] ~= nil then
				local replace_type = type(replace[nums])
				if replace_type == "string" or replace_type == "number" then
					return replace[nums]
				else
					return ""
				end
			end

			return ""
		end)
	end

	local return_str = ""
	while true do
		local start_pos , end_pos , color = string.find(str , "%[color=(#[a-f0-9]+)%]")
		if start_pos == nil then break end
		local start_pos_2 , end_pos_2 = string.find(str , "%[/color%]" , end_pos)
		if start_pos_2 == nil then break end
		local first_str = string.sub(str , 0 , start_pos - 1)
		local second_str = string.sub(str , end_pos + 1 , start_pos_2 - 1)

		return_str = return_str .. first_str .. second_str
		str = string.sub(str , end_pos_2 + 1)
	end


	return return_str .. str
end


return InfoLayer