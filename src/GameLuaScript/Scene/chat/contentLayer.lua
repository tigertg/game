--[[消息具体内容]]

local KNBtn = requires(IMG_PATH , "GameLuaScript/Common/KNBtn")
local oneMessage = requires(IMG_PATH , "GameLuaScript/Scene/chat/oneMessage")


local contentLayer = {
	layer,
	msg_layer,
	chatbox_layer,
}

function contentLayer:new(message_type)
	local this = {}
	setmetatable(this , self)
	self.__index = self

	this.layer = display.newLayer()

	-- 显示背景
--	if message_type == "talk" then
--		local info_bg = display.newSprite(IMG_PATH .. "image/scene/chat/info_bg_small.png")
--		setAnchPos(info_bg , 15 , 200)
--		this.layer:addChild(info_bg)
--	else
--		local info_bg = display.newSprite(IMG_PATH .. "image/scene/chat/info_bg_big.png")
--		setAnchPos(info_bg , 15 , 107)
--		this.layer:addChild(info_bg)
--	end


	-- 显示消息内容
	this:refresh(message_type)

	-- 显示聊天框
	if message_type == "talk" then
		this:showChatBox()
	end

	return this
end


function contentLayer:refresh(message_type)
	local data = DATA_Info:get_type("_G_message_" .. message_type)
	
	if data == nil then
		data = {}
	end

	if self.msg_layer ~= nil then
		self.msg_layer:removeFromParentAndCleanup(true)
	end

	self.msg_layer = display.newLayer()


	if #data > 0 then
		-- 展示滚动消息
		local scroll_height = 560
		local scroll_y = 108
		if message_type == "talk" then
			scroll_height = 470
			scroll_y = 200
		end

		local scroll = KNScrollView:new( 15 , scroll_y , 450 , scroll_height , 10 , false)
		for i = 1 , #data do
			local one_message = oneMessage:new( data[i] , message_type , {
				index = i,
				first_line = i == 1,
				parent = scroll
			})
			scroll:addChild(one_message:getLayer() , one_message)
		end

		if #data > 1 then
			scroll:setIndex(#data , true)
		end
		
		self.msg_layer:addChild( scroll:getLayer() )
	else
		local empty_sprite = display.newSprite(IMG_PATH .. "image/common/empty.png")
		setAnchPos(empty_sprite , display.cx , display.cy , 0.5 , 0.5)
		self.msg_layer:addChild( empty_sprite )
	end


	self.layer:addChild( self.msg_layer , 1)
end


function contentLayer:showChatBox()
	if self.chatbox_layer ~= nil then
		self.chatbox_layer:removeFromParentAndCleanup(true)
	end

	self.chatbox_layer = display.newLayer()

	local enter_bg , input_bg , textfield , windowlayer , send_btn , cancel_btn , haveHornNumSp , hornNum

	-- 切换真假输入框的状态
	local function changeStauts(status)
		if status == true then
			enter_bg:setVisible(false)
			input_bg:setVisible(true)

			windowlayer:setPosition(45 , 516)
			textfield:setString("")
			textfield:attachWithIME()

			send_btn:setVisible(true)
			cancel_btn:setVisible(true)
			haveHornNumSp:setVisible(true)
			hornNum:setVisible(true)
			
		else
			enter_bg:setVisible(true)
			input_bg:setVisible(false)

			windowlayer:setPosition(45 , 147)
			textfield:setString("点击输入信息")
			textfield:detachWithIME()

			send_btn:setVisible(false)
			cancel_btn:setVisible(false)
			
			haveHornNumSp:setVisible(false)
			hornNum:setVisible(false)
		end
	end

	-- 输入框
	textfield = CCTextFieldTTF:textFieldWithPlaceHolder("点击输入信息" , FONT , 22)
	display.align(textfield , display.CENTER_LEFT , 0 , 0)
	textfield:setColor( ccc3( 0x4d , 0x15 , 0x15 ) )
	textfield:setColorSpaceHolder( ccc3( 0x4d , 0x15 , 0x15 ) )
	
	windowlayer = WindowLayer:createWindow()
	windowlayer:setAnchorPoint( ccp(0 , 0.5) )
	windowlayer:setContentSize( CCSizeMake(395 , 100) )
	windowlayer:addChild( textfield )
	self.chatbox_layer:addChild( windowlayer , 1 )


	-- 假输入框背景
	enter_bg = KNBtn:new(IMG_PATH .. "image/scene/chat", {"enter.png"} , 16 , 105 , {
		callback = function()
			changeStauts(true)
		end
	}):getLayer()
	self.chatbox_layer:addChild(enter_bg)

	-- 真输入框的背景
	input_bg = display.newSprite(IMG_PATH .. "image/scene/chat/input_bg.png")
	setAnchPos(input_bg , 14 , 435)			
	self.chatbox_layer:addChild(input_bg)
	
	--拥有喇叭数
	haveHornNumSp = display.newSprite(IMG_PATH .. "image/scene/chat/have_horn_num.png")
	setAnchPos( haveHornNumSp , 324 , 445 )			
	self.chatbox_layer:addChild( haveHornNumSp )
	--喇叭数
	local isHorn , hornTotleNum = DATA_Bag:getTypeNum( "prop" , "horn" )
	hornNum = display.strokeLabel( hornTotleNum or 0  ,  415  , 438 , 18 , ccc3(0xff , 0xfc , 0xd3 ) , nil , nil ,
				 {
				 	 dimensions_width = 80 , 
				 	 dimensions_height = 30 , 
				 	 align = 0 
				 })
	self.chatbox_layer:addChild( hornNum )

	-- 发送输入框
	send_btn = KNBtn:new(IMG_PATH .. "image/common", {"btn_bg.png" , "btn_bg_pre.png"} , 90 , 445 , {
		front = IMG_PATH .. "image/common/send.png",
		scale = true,
		noHide = true,
		callback = function()
			if textfield:getString() == "" then 
				KNMsg:getInstance():flashShow("没有输入内容")
			elseif textfield:getCharCount() > 50 then
				KNMsg:getInstance():flashShow("最多输入50字")
			else
				if not isHorn then
					KNMsg:getInstance():flashShow("亲，你的喇叭不足，请至商城购买道具")
				else
					HTTP:call("message" , "talk" , {
						content = textfield:getString()
					} , {
						success_callback = function(data)
							isHorn , hornTotleNum = DATA_Bag:getTypeNum( "prop" , "horn" )
							hornNum:setString( hornTotleNum )
							changeStauts(false)
							-- self:refresh("talk")
						end
					})
				end
			end
		end
	}):getLayer()
	self.chatbox_layer:addChild( send_btn )


	-- 取消按钮
	cancel_btn = KNBtn:new(IMG_PATH .. "image/common", {"btn_bg.png" , "btn_bg_pre.png"} , 210 , 445 , {
		front = IMG_PATH .. "image/common/cancel.png",
		scale = true,
		noHide = true,
		callback = function()
			changeStauts(false)
		end
	}):getLayer()
	self.chatbox_layer:addChild( cancel_btn )


	-- 默认为假输入框状态
	changeStauts(false)


	self.layer:addChild( self.chatbox_layer , 10)
end

	
function contentLayer:getLayer()
	return self.layer
end


return contentLayer
