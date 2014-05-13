local PATH = IMG_PATH.."image/scene/newguy/"
local SCENECOMMON = IMG_PATH.."image/scene/common/"
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")--require "GameLuaScript/Common/KNBtn"
local Config_General = requires(IMG_PATH,"GameLuaScript/Config/Hero")
local KNRadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup") 
local KNShowbylist = requires(IMG_PATH , "GameLuaScript/Common/KNShowbylist")
local KNInputText = requires(IMG_PATH, "GameLuaScript/Common/KNInputText")
--[[
	首页
]]
local generals = {
	"1325",
	"1311",
	"1308",
}

local NewLayer= {
	layer,
	viewLayer = nil,
	selectLayer = nil,
	selectIndex = 1,
	open_id = nil,
	scroll,
	group
}
function NewLayer:new(open_id , step)
	local this = {}
	setmetatable(this , self)
	self.__index = self

	this.open_id = open_id
	
	this.sex = 1
	this.nickStr = ""
	this.general_select = 1
	
	this.layer = display.newLayer()

	this:step(step)

	return this.layer
end
function NewLayer:step(step)
	-- step = 5
	
	if self.viewLayer ~= nil then
		self.layer:removeChild(self.viewLayer , true)
	end

	print("open_id: " .. self.open_id)

	self.viewLayer = display.newLayer()
	local next_step = false
	
	if step == 1 then
		self.viewLayer:addChild( display.newSprite(PATH .. "bg_2.jpg" , display.cx , display.cy ) )
		
		local text2 = display.newSprite(PATH .. "text01_02.png")
		setAnchPos( text2 , 230 , 222 , 0.5 , 0.5 )
		self.viewLayer:addChild( text2 )
		text2:setScale(0.01)
		transition.scaleTo( text2 , {delay = 0.5,  time = 0.3 , scale = 1 ,easing = "BACKOUT" })
		
		
		local text1 = display.newSprite(PATH .. "text01_01.png")
		setAnchPos( text1 , display.cx , -50 , 0.5 , 1  )
		self.viewLayer:addChild( text1 )
		transition.fadeIn( text1 , { time = 0.3 , delay = 0.5 } )
		transition.moveTo( text1 , { time = 0.8 , y = 132 , onComplete = 
			function() 
				self.viewLayer:addChild( display.strokeLabel("点击继续.." , display.cx - 55 , display.height - 50 , 24 , ccc3( 0xff , 0xff , 0xff ) ) )
				next_step = true
				
				self.viewLayer:addTouchEventListener(function()
					if next_step then
						echoLog("GUIDE" , "next 2")
						next_step = false
						self:step(2)
					end
				end)
				self.viewLayer:setTouchEnabled(true)
			end})
			
		self.layer:addChild( self.viewLayer )
	elseif step == 2 then
		self.viewLayer:addChild( display.newSprite(PATH .. "bg_3.jpg" , display.cx , display.cy ) )
		
		local text2 = display.newSprite(PATH .. "text02_02.png")
		setAnchPos( text2 , 170 , 560 , 0.5 , 0.5 )
		self.viewLayer:addChild( text2 )
		text2:setScale(0.01)
		transition.scaleTo( text2 , {delay = 0.3,  time = 0.3 , scale = 1 ,easing = "BACKOUT" ,onComplete = 
				function()
						local text3 = display.newSprite(PATH .. "text02_03.png")
						setAnchPos( text3 , 260 , 680 , 0.5 , 0.5 )
						self.viewLayer:addChild( text3 )
						text3:setScale(0.01)
						transition.scaleTo( text3 , { delay = 0.3,  time = 0.3 , scale = 1 ,easing = "BACKOUT" })
				end
				 })

		local text1 = display.newSprite(PATH .. "text02_01.png")
		setAnchPos( text1 , display.cx , -50 , 0.5 , 1  )
		self.viewLayer:addChild( text1 )
		transition.fadeIn( text1 , { time = 0.3 , delay = 0.5 } )
		transition.moveTo( text1 , { time = 0.8 , y = 132 , onComplete = 
			function() 
				self.viewLayer:addChild( display.strokeLabel("点击继续.." , display.cx - 55 , display.height - 50 , 24 , ccc3( 0xff , 0xff , 0xff ) ) )
				next_step = true
				
				self.viewLayer:addTouchEventListener(function()
					if next_step then
						echoLog("GUIDE" , "next 3")
						next_step = false
						self:step(3)
					end
				end)
				self.viewLayer:setTouchEnabled(true)
			end})
			
		self.layer:addChild( self.viewLayer )
		
	elseif step == 3 then
		self.viewLayer:addChild( display.newSprite(PATH .. "bg_4.jpg" , display.cx , display.cy ) )
		
		local text2 = display.newSprite(PATH .. "text03_03.png")
		setAnchPos( text2 , 170 , 500 , 0.5 , 0.5 )
		self.viewLayer:addChild( text2 )
		text2:setScale(0.01)
		transition.scaleTo( text2 , {delay = 0.3,  time = 0.3 , scale = 1 ,easing = "BACKOUT" ,onComplete = 
				function()
						local text3 = display.newSprite(PATH .. "text03_02.png")
						setAnchPos( text3 , 160 , 680 , 0.5 , 0.5 )
						self.viewLayer:addChild( text3 )
						text3:setScale(0.01)
						transition.scaleTo( text3 , { delay = 0.3,  time = 0.3 , scale = 1 ,easing = "BACKOUT" })
				end
				 })
		
		local text1 = display.newSprite(PATH .. "text03_01.png")
		setAnchPos( text1 , display.cx , -50 , 0.5 , 1  )
		self.viewLayer:addChild( text1 )
		transition.fadeIn( text1 , { time = 0.3 , delay = 0.5 } )
		transition.moveTo( text1 , { time = 0.8 , y = 132 , onComplete = 
			function() 
				self.viewLayer:addChild( display.strokeLabel("点击继续.." , display.cx - 55 , display.height - 50 , 24 , ccc3( 0xff , 0xff , 0xff ) ) )
				next_step = true
				
				self.viewLayer:addTouchEventListener(function()
					if next_step then
						echoLog("GUIDE" , "next 4")
						next_step = false
						self:step(4)
					end
				end)
				self.viewLayer:setTouchEnabled(true)
			end})
		self.layer:addChild( self.viewLayer )
	elseif step == 4 then
		self.viewLayer:addChild( display.newSprite(PATH .. "bg_5.jpg" , display.cx , display.cy ) )
		
		local text2 = display.newSprite(PATH .. "text04_02.png")
		setAnchPos( text2 , 150 , 650 , 0.5 , 0.5  )
		self.viewLayer:addChild( text2 )
		text2:setScale(0.01)
		transition.scaleTo( text2 , {delay = 0.3,  time = 0.3 , scale = 1 ,easing = "BACKOUT" ,onComplete = 
				function()
						local text3 = display.newSprite(PATH .. "text04_03.png")
						setAnchPos( text3 , 330 , 620 , 0.5 , 0.5  )
						self.viewLayer:addChild( text3 )
						text3:setScale(0.01)
						transition.scaleTo( text3 , { delay = 0.3,  time = 0.3 , scale = 1 ,easing = "BACKOUT" })
				end
				 })
		
		local text1 = display.newSprite(PATH .. "text04_01.png")
		setAnchPos( text1 , display.cx , -50 , 0.5 , 1  )
		self.viewLayer:addChild( text1 )
		transition.fadeIn( text1 , { time = 0.3 , delay = 0.5 } )
		transition.moveTo( text1 , { time = 0.8 , y = 132 , onComplete = 
			function() 
				self.viewLayer:addChild( display.strokeLabel("点击继续.." , display.cx - 55 , display.height - 50 , 24 , ccc3( 0xff , 0xff , 0xff ) ) )
				next_step = true
				
				self.viewLayer:addTouchEventListener(function()
					if next_step then
						echoLog("GUIDE" , "next 5")
						next_step = false
						self:step(5)
					end
				end)
				self.viewLayer:setTouchEnabled(true)
			end})
		self.layer:addChild( self.viewLayer )
	elseif step == 5 then
	
		local text1 = display.newSprite(PATH .. "text05_01.png")
		setAnchPos( text1 , display.cx , -50 , 0.5 , 0.5  )
		self.viewLayer:addChild( text1 )
		transition.fadeIn( text1 , { time = 0.3 , delay = 0.5 } )
		transition.moveTo( text1 , { time = 3 , y = display.cy , onComplete = 
			function() 
				self.viewLayer:addChild( display.strokeLabel("点击继续.." , display.cx - 55 , display.height - 50 , 24 , ccc3( 0xff , 0xff , 0xff ) ) )
				next_step = true
				
				self.viewLayer:addTouchEventListener(function()
					if next_step then
						echoLog("GUIDE" , "next 6")
						next_step = false

						self:selectGeneral()
					end
				end)
				self.viewLayer:setTouchEnabled(true)
			end})
		self.layer:addChild( self.viewLayer )
	else
		self:selectGeneral()		
	end
end


function NewLayer:regName()
	if self.viewLayer ~= nil then
		self.layer:removeChild(self.viewLayer , true)
	end
	self.viewLayer = display.newLayer()

	local bg = display.newSprite(IMG_PATH .. "image/scene/login/bg.jpg")
	setAnchPos(bg , display.cx , display.cy , 0.5 , 0.5 )
	self.viewLayer:addChild(bg)
	
	--昵称
	local nicknameBg = display.newSprite(PATH .. "nickname_bg.png")
	setAnchPos(nicknameBg , display.cx , 401 , 0.5 , 0 )
	self.viewLayer:addChild(nicknameBg)
	
	--角色背景
	local roleBg = display.newSprite(PATH .. "role_bg.png")
	setAnchPos(roleBg , display.cx , 530 , 0.5 , 0 )
	self.viewLayer:addChild(roleBg)
	
	--性别选择
	local KNRadioGroup = requires(IMG_PATH,"GameLuaScript/Common/KNRadioGroup")
	local group = KNRadioGroup:new()
	for i = 1 , 2 do
		local sexBtn = KNBtn:new( COMMONPATH , {"sex1.jpg" , "select1.png"} , 150 + (i-1)*105 , 567 , {
 		front = COMMONPATH .. "sex" .. i .. ".jpg" , 
		callback = function()
			self.sex = i
		end
		} , group):getLayer()
		self.viewLayer:addChild(sexBtn)
	end
	
	
	local nicknameText , nickInputBg , effBg
	--修改昵称
	local function changeNick()
		nicknameText:startInput()
		
		effBg:setVisible(true)
		setAnchPos( effBg , 140 + 118 , 465 + 16 , 0.5 , 0.5  )
	end
	
--	nicknameText = CCTextFieldTTF:textFieldWithPlaceHolder("请输入昵称" , FONT , 20)
--	display.align(nicknameText , display.CENTER_LEFT , 0 , 0)
--	nicknameText:setColor( ccc3( 0xff , 0xfb , 0xd4 ) )
--	nicknameText:setColorSpaceHolder( ccc3( 0x4d , 0x15 , 0x15 ) )
--	nicknameText:attachWithIME()
--	
--	
--	nickname_mask = WindowLayer:createWindow()
--	nickname_mask:setAnchorPoint( ccp(0 , 0.5) )
--	nickname_mask:setContentSize( CCSizeMake(212 , 28) )
--	nickname_mask:addChild( nicknameText )
--	nickname_mask:setPosition(150 , 480)
--	self.viewLayer:addChild( nickname_mask , 10 )

	nicknameText = KNInputText:new( { width = 212 , 
										height = 28 , 
										size = 20 , 
										defStr = "请输入昵称" , 
										defColor = ccc3( 0xff , 0xfb , 0xd4 ) , 
										inputColor = ccc3( 0x4d , 0x15 , 0x15 ) 
										} )
	setAnchPos( nicknameText:getLayer() , 150 , 480 )
								
	self.viewLayer:addChild( nicknameText:getLayer() , 10 )
	
	--输入条
	nickInputBg = KNBtn:new(IMG_PATH .. "image/scene/login", {"input_bg.png"} , 140 , 465 , {
	callback = function()
		changeNick()
	end
	}):getLayer()
	self.viewLayer:addChild(nickInputBg)
	effBg = display.newSprite(IMG_PATH .. "image/scene/login/eff_bg.png")
	effBg:setVisible( false )
	self.viewLayer:addChild( effBg )
	local function createAction()
			local action
			action = getSequenceAction( CCFadeIn:create( 0.5 ) , CCFadeOut:create( 0.5 ) , CCCallFunc:create(
			function()
				effBg:runAction(createAction())
			end))	
			return action
	end
	effBg:runAction(createAction())	
	
	-- 确定按钮
	local okBtn = KNBtn:new( PATH , {"ok.png" , "ok_pre.png"} , 390 , 413 , {
		callback = function()
			local niceID = string.trim( nicknameText:getString())
			if niceID ~= "" and string.len( niceID ) <= 18 then
				nicknameText:stopInput()
				self.nickStr = niceID

				-- 发请求
				local post_data = {
					open_id = self.open_id ,
					general_select = self.general_select ,
					channel = CHANNEL_ID,
					sex = self.sex == 2 and 0 or 1 , 
					name = self.nickStr
				}
				for k , v in pairs(device.infos) do
					post_data[k] = v
				end
				
				-- 发请求
				HTTP:call("login" , "reg" , post_data , {
					success_callback = function()
						if CHANNEL_ID == "appFame" then
							LuaCallAppFrameSDK:getInstance():setRoleIdRoleName(DATA_Session:get("uid"),DATA_User:get("name"))
						elseif CHANNEL_ID == "appFameOfficial" then
							LuaCallAppFameSDKOfficial:getInstance():setRoleIdRoleName(DATA_Session:get("uid"),DATA_User:get("name"))
						end
					end
				})
			else
				KNMsg.getInstance():flashShow("昵称输入不合法")
			end
		end
	}):getLayer()
	self.viewLayer:addChild( okBtn )
	
	self.layer:addChild( self.viewLayer )
end

function NewLayer:selectGeneral()
	if self.viewLayer ~= nil then
		self.layer:removeChild(self.viewLayer , true)
	end
	self.viewLayer = display.newLayer()
	
	local bg = display.newSprite(PATH .. "bg.png")
	setAnchPos(bg , 0 , 0)
	self.viewLayer:addChild(bg)

	local title_bg = display.newSprite(PATH .. "title_bg.png")
	setAnchPos(title_bg , display.cx , 730 , 0.5)
	self.viewLayer:addChild(title_bg)

	local title = display.newSprite(PATH .. "title.png")
	setAnchPos(title , display.cx , 740 , 0.5)
	self.viewLayer:addChild(title)

	-- 头像选择
	local name_bg = display.newSprite(PATH .. "name_bg.png")
	setAnchPos(name_bg , display.cx , 135 , 0.5)
	self.viewLayer:addChild(name_bg)

	--  姓名-人物
	local head_bg = display.newSprite(PATH .. "head_bg.png")
	setAnchPos(head_bg , display.cx , 200 , 0.5)
	self.viewLayer:addChild(head_bg)
	
	
	self.group = KNRadioGroup:new()
	for i = 1 , 3 do
		local reg_button = KNBtn:new(SCENECOMMON , {"box.png", "select1.png"} , 83 + (i - 1) * 123 , 210 , {
			front = getImageByType(generals[i] , "s"),
			frontScale = {1 , -3 , 3},
			noHide = true,
			selectZOrder = 50,
			selectOffset = {-3,3},
			scale = true,
			callback = function()
--				self:selectOne(i)
				self.scroll:setIndex(i)
			end
		},self.group)
		self.viewLayer:addChild( reg_button:getLayer() )

--[[
		local logo_bg = display.newSprite(SCENECOMMON .. "box.png")
		setAnchPos(logo_bg , 77 + (i - 1) * 83 , 208 , 0.5)
		self.viewLayer:addChild(logo_bg)

		local logo = display.newSprite(IMG_PATH .. "image/hero/s_general" .. generals[i] .. ".png")
		setAnchPos(logo , 75 + (i - 1) * 83 , 217 , 0.5)
		self.viewLayer:addChild(logo)
]]

		local name = display.newSprite(PATH .. "name_" .. i .. ".png")
		setAnchPos(name , 113 + (i - 1) * 123 , 150 , 0.5)
		self.viewLayer:addChild(name)
	end

	local light = display.newSprite(PATH .. "light.png")
	setAnchPos(light , display.cx , 515 , 0.5 , 0.5)
	self.viewLayer:addChild(light)

	local light_action
	light_action = function(angle)
		transition.rotateTo(light , {time = 10 , angle = angle , onComplete = function()
			if angle == 180 then angle = 360 else angle = 180 end
			light_action(angle)
		end})
	end
	light_action(180)
	

	--[[注册按钮]]
	local reg_callback = function()
		self.general_select = self.scroll:getCurIndex()

		self:regName()
	end


	local reg_button = KNBtn:new(COMMONPATH , {"btn_bg_red.png","btn_bg_red_pre.png"} , 165 , 60 , {
		front = COMMONPATH .. "confirm_big.png",
		scale = true,
		callback = reg_callback
	})
	self.viewLayer:addChild( reg_button:getLayer() )


	self.layer:addChild( self.viewLayer )


--	self:selectOne(1)
	
	self.scroll = KNScrollView:new(0, 100, 480, 600, 0, true, 1, {
		page_callback = function()
			self.group:chooseByIndex(self.scroll:getCurIndex())
		end
	})
	for i = 1, 3 do
		local temp = self:selectOne(i)
		self.scroll:addChild(temp, temp)
	end
	self.scroll:alignCenter()
	self.layer:addChild(self.scroll:getLayer())
	
end

function NewLayer:selectOne(index)
	index = tonumber(index)
	self.selectIndex = index

	local cid = generals[index]

	local layer = display.newLayer();

	local bg = display.newSprite(PATH .. "card_bg_" .. index .. ".png")
	setAnchPos(bg , display.cx , 315 , 0.5)
	layer:addChild(bg)
	


	local big_icon = display.newSprite(getImageByType(cid , "b"))
	setAnchPos(big_icon , display.cx , 385 , 0.5)
	layer:addChild(big_icon)
	
	local job = display.newSprite(COMMONPATH.."job"..getConfig("general", generals[index], "role")..".png")
	setAnchPos(job, 130, 580)
	layer:addChild(job)

	local name_bg = display.newSprite(PATH .. "banner_bg.png")
	setAnchPos(name_bg , 315 , 540)
	layer:addChild(name_bg)

	local name = display.newSprite(PATH .. "banner_" .. index .. ".png")
	setAnchPos(name , 315 , 545)
	layer:addChild(name)


	local star_num = Config_General[cid]["star"]
	local star_init_x = 175 + (5 - star_num) * 14
	for i = 1 , star_num do
		local star = display.newSprite(COMMONPATH .. "star.png")
		setAnchPos(star , star_init_x + (i - 1) * 28 , 655)
		layer:addChild(star)
	end

	return layer
end


return NewLayer
