-- 设置界面
local KNBtn = requires(IMG_PATH,"GameLuaScript/Common/KNBtn")
local KNMask = requires(IMG_PATH,"GameLuaScript/Common/KNMask")
local KNClock = requires(IMG_PATH,"GameLuaScript/Common/KNClock")
local KNInputText = requires(IMG_PATH,"GameLuaScript/Common/KNInputText")
local KNRadioGroup = requires(IMG_PATH , "GameLuaScript/Common/KNRadioGroup")
local oneMessage = requires(IMG_PATH , "GameLuaScript/Scene/chat/oneMessage")

local PATH = IMG_PATH .. "image/scene/chat/"
local curType , data , textfield ,  haveHornNumSp , hornNum , group , scroll , input_bg ,  send_btn , empty_sprite , toText , findPlay
local friendData = nil
local isAll = true		--好友聊天中是否显示全部
local newAddY = 20		--输入框新调整坐标
local scroll_y = 420  + newAddY	 
local scroll_height = 340 - newAddY
local delayTime = 5
local M = {

}
--设置聊天对象
function M:setFriendData( tempData )
	if curType == "friend" then
		friendData = tempData
		toText:setString( friendData and "我对【" .. friendData.name .."】说:" or "" )
		isAll = false
		self:filtreFriendData()
		self:createList()
		delayTime = 0
	end
end
function M:new( params )
	local this = {}
	setmetatable(this , self)
	self.__index = self
	TALK = this
	params = params or {}
	curType = params.type or "world"
	friendData = params.friendData
	if friendData then isAll = false end
	
	
	this.baseLayer = display.newLayer()
	this.viewLayer = display.newLayer()
	this.tabLayer = display.newLayer()
	this.inputLayer =display.newLayer()
	
	DATA_Info:setIsMsg( false )	--消除消息状动画
	
	local mask , layer ,  tableElement 
	layer = display.newLayer()
	
	this.baseLayer:addChild( layer )
	this.baseLayer:addChild( this.tabLayer )
	
	-- 背景
	layer:addChild( display.newSprite(PATH .. "talk_bg.png" , display.cx , 327 , 0.5 , 0 ) )
	this:showChatBox()
	--关闭
	local closeBtn = KNBtn:new( PATH , { "close.png" ,"close_press.png"}, 420 , 765 ,
	{
		priority = -130,
		callback = 
		function()
			DATA_Info:setIsMsg( false )
			DATA_Info:setIsOpen()
			mask:remove()
		end
	}):getLayer()
	layer:addChild( closeBtn )

	
	
	
	tableElement = { "world" , "gang" , "friend" }
	local startX,startY = 20 , 767
	group = KNRadioGroup:new()
	for i = 1, #tableElement do
		local temp = KNBtn:new( PATH , {"btn_gray.png" , "btn_" .. tableElement[i] .. ".png" }  , startX , startY , {
			disableWhenChoose = true,
			priority = -130 , 
			upSelect = true,
			id = tableElement[i],
			front = PATH..tableElement[i].."_text.png" ,
			callback=
			function()
				this:changeStauts( false )
				curType = tableElement[i]
				this:refreshData()
			end
		},group)
		this.tabLayer:addChild(temp:getLayer())
		startX = startX + temp:getWidth() + 18
	end
	group:chooseById( curType , false )	--激活的选项
	this:refreshData()
	
	this.baseLayer:addChild( this.viewLayer )
	this.baseLayer:addChild( this.inputLayer , 50 )
	
	setAnchPos( this.baseLayer , 0 , display.height )
	transition.moveTo( this.baseLayer , { delay = 0.5 , time = 0.5 , y = 0 , easing = "BACKOUT" })
	mask = KNMask:new( { opacity = 0 , item = this.baseLayer , priority = -129 } )
	return mask
end
function M:refreshData()
	self:setState()
	if curType == "world" then
		HTTP:call("message" , "gettalk" , {} , {
			success_callback = function()
				data = DATA_Info:get_type("_G_message_talk")
				self:createList()
			end
		})
	elseif curType == "gang" then
		HTTP:call("alliance" , "getchat" , {} , {
			success_callback = function()
				data = DATA_Info:get_type("gang")
				if data.code == 1  then
					KNMsg:getInstance():flashShow("亲，你还没有加入一个帮会！")
					curType = "world"
					group:chooseById( curType , false )	--激活的选项
					data = DATA_Info:get_type("_G_message_talk")
					if not data then
						group:chooseById( curType , true )
					end
					return
				end
				self:getGangData()
				self:createList( )
			end
		})
	elseif curType == "friend" then
		HTTP:call("message" , "get_siliao" , {} , {
			success_callback = function()
				self:filtreFriendData()
				self:createList()
			end
		})
	end
end
function M:gangDataCell( tempData )
	local tempItem = {}
	tempItem[ #tempItem + 1 ] = tempData.title
	tempItem[ #tempItem + 1 ] = tempData.name
	tempItem[ #tempItem + 1 ] = tempData.content
	tempItem[ #tempItem + 1 ] = tempData.time or 0
	tempItem[ #tempItem + 1 ] = tempData.uid
	
	local temp = {}
	
	temp[ "msg" ] = tempItem
	
	local str = ( tempData.title ~= "" ) and "【#s#】" or "#s#"
	temp[ "template" ] = str .. ( tempData.time and  "【#s#】#s#(#s#)" or "【#s#】#s#" )
	
	return temp
end
--格式化帮派聊天数据
function M:getGangData()
	data = DATA_Info:get_type("gang")
	data = data.chat or {}
	local tempData = {}
	for i = 1 , #data do
		tempData[ #tempData + 1 ] = self:gangDataCell(data[i])
	end
	data = tempData
end

function M:getType()
	return curType
end

function M:addItem( _data , type )
	if type == "gang" then
		self:getGangData()
	elseif type == "friend" then
--		_data = DATA_Info:get_type("friend")
--		_data = _data[#_data]
--		self:setFriendData()
		self:filtreFriendData()
		self:createList()
		return 
	else
		data = DATA_Info:get_type("_G_message_talk")
	end
	
	local i = #data
	if i<=1 then
		self:createList()
	else
		i = type == "friend" and table.nums( DATA_Info:get_type("friend") ) or  #data
		local one_message = oneMessage:talknew( _data , nil , {
			type = curType ,
			index = i,
			first_line = true,
			parent = scroll ,
			color = ccc3( 0xfe , 0xfb , 0xd2 ) ,
			backFun = function( data ) self:setFriendData( data ) end ,
		})
		scroll:addChild( one_message:getLayer() , one_message )
	
		--实时接收到的数据添加进来后 重置滚动条
		if #data > 1 then
			scroll:setIndex( i , true )
		end
	end
end
--过滤好友聊天数据
function M:filtreFriendData( tempData )
	data = DATA_Info:get_type( "friend" ) or {}
	local tempData = isAll and data or {}
	if friendData then
		for key , v in pairs( data ) do
			if not isAll then
				if tonumber( v.uid ) == tonumber( friendData.uid ) then
					tempData[ #tempData + 1 ] = v
				end
			end
		end
		data = tempData
	end
end
function M:createList()
	local layer = display.newLayer()
	
	local isCreate = false
	if self.viewLayer then
		self.viewLayer:removeFromParentAndCleanup( true )
		self.viewLayer = nil
		self.viewLayer = display.newLayer()
		self.baseLayer:addChild( self.viewLayer )
		self.viewLayer:addChild( layer )
		isCreate = true
	end
	
	if curType == "friend" then
		--显示当前玩家聊天记录/所有聊天记录
		local allSingleBtn 
		allSingleBtn = KNBtn:new( COMMONPATH , { "long_btn.png" , "long_btn_pre.png" }, 310 , 770 ,
		{
			priority = -130,
			front = PATH .. ( isAll and "show_all.png" or  "show_single.png" ) , 
			callback = 
			function()
				if isAll and not friendData then
					KNMsg:getInstance():flashShow("请选择说话对像！")
					return
				end
					isAll = not isAll
					if isAll then
						allSingleBtn:setFront( PATH .. "show_all.png" )
					else
						allSingleBtn:setFront( PATH .. "show_single.png" )
					end
					self:filtreFriendData()
					self:createList()
				end
			
		})
		layer:addChild( allSingleBtn:getLayer() )
	end
	if #data > 0 then
		-- 展示滚动消息
		scroll = KNScrollView:new(35 , scroll_y , 420 , scroll_height , 2 , false , 0 , {priority = -130})
		for i = 1 , #data do
			local one_message = oneMessage:talknew( data[i] , nil , {
				type = curType ,
				index = i,
				first_line = true,
				parent = scroll ,
				color = ccc3( 0xfe , 0xfb , 0xd2 ) ,
				backFun = function( data ) self:setFriendData( data ) end ,
			})
			scroll:addChild(one_message:getLayer() , one_message)
		end
		--生成后定位
		if #data > 1 then
			scroll:setIndex(#data , true)
		end
		layer:addChild( scroll:getLayer() )
		
	else
		--没有数据的时候，显示为空
		empty_sprite = display.newSprite(IMG_PATH .. "image/common/empty.png")
		setAnchPos(empty_sprite , display.cx , display.cy + 120 , 0.5 , 0.5)
		layer:addChild( empty_sprite )
	end
end


function M:changeStauts( status )
	local moveLength = 0
	local friendAddY = curType == "friend" and 30 or 0 
	if status == true then
		textfield:startInput()
		scroll_y = 520
		scroll_height = 240
		moveLength = 80
	else
		textfield:stopInput( true )
		
		scroll_y = 420 + newAddY
		scroll_height = 340 - newAddY
		
		moveLength = 0
	end
	setAnchPos( haveHornNumSp , 26 , 331 + moveLength + newAddY )	
	setAnchPos( hornNum , 115 , 324 + moveLength + newAddY)	
	setAnchPos(send_btn , 373 , 363 + moveLength + newAddY)
	setAnchPos(input_bg , 14 , 360 + moveLength + newAddY)
	setAnchPos( textfield:getLayer() , 30 , 383 + moveLength + newAddY)
	setAnchPos( toText , 130  , 315  + moveLength + newAddY  )
	setAnchPos( findPlay:getLayer() ,13 , 315 + moveLength + newAddY  )
	
	self:createList()
end
function M:showChatBox( )
	-- 切换真假输入框的状态
	textfield = KNInputText:new( { width = 365 , 
									height = 28 , 
									size = 20 , 
									defStr = "点击输入信息" , 
									existStr = nil ,
									defColor = ccc3( 0x4d , 0x15 , 0x15 ) , 
									inputColor = ccc3( 0x4d , 0x15 , 0x15 ) 
									} )
	setAnchPos( textfield:getLayer() , 30  , 383 + newAddY )
	self.inputLayer:addChild( textfield:getLayer() , 10 )
	

	-- 真假输入框的背景
	input_bg =  KNBtn:new(PATH, {"talk_input_bg.png"} , 14 , 360 + newAddY  , {
		priority = -130 ,  
		callback = function()
			self:changeStauts(true)
		end
		}):getLayer()
	self.inputLayer:addChild(input_bg)
	--说话提示文字
	toText = display.strokeLabel( friendData and "我对【" .. friendData.name .."】说:" or ""  ,  130  , 315  + newAddY , 20 , ccc3(0xff , 0xfc , 0xd3 ) , nil , nil ,
				 {
				 	 dimensions_width = 200 , 
				 	 dimensions_height = 30 , 
				 	 align = 0 
			 	})
 	self.inputLayer:addChild( toText )
 	--查找玩家
	findPlay = KNBtn:new( COMMONPATH , { "long_btn.png" , "long_btn_pre.png" } , 13 , 315 + newAddY , {
							priority = -131 , 
							front = IMG_PATH .. "image/scene/friend/find_player_text.png" ,
							callback = function()
								local friendLayer = requires(IMG_PATH , "GameLuaScript/Scene/friend/friendLayer")
								friendLayer:findFriend( { type = "talk" , backFun = function( tempData ) self:setFriendData( tempData ) end } )
							end
							})
	self.inputLayer:addChild( findPlay:getLayer() )

	--拥有喇叭数
	haveHornNumSp = display.newSprite(PATH .. "have_horn_num.png")
	setAnchPos( haveHornNumSp , 26 , 331 + newAddY )			
	self.inputLayer:addChild( haveHornNumSp )
	
	--喇叭数
	local isHorn , hornTotleNum = DATA_Bag:getTypeNum( "prop" , "horn" )
	hornNum = display.strokeLabel( hornTotleNum or 0  ,  115  , 324  + newAddY , 18 , ccc3(0xff , 0xfc , 0xd3 ) , nil , nil ,
				 {
				 	 dimensions_width = 80 , 
				 	 dimensions_height = 30 , 
				 	 align = 0 
				 })
	self.inputLayer:addChild( hornNum )
	
	local function delayFun()
		delayTime = delayTime - 1
		if delayTime <= 0 then
			KNClock:removeTimeFun( "talk" )
			delayeTime = 0
		end
	end
	
	-- 发送输入框
	send_btn = KNBtn:new(IMG_PATH .. "image/common", {"btn_bg.png" , "btn_bg_pre.png"} , 373 , 363 + newAddY , {
		priority = -130 ,
		front = IMG_PATH .. "image/common/send.png",
		scale = true,
		noHide = true,
		callback = function()
			if KNClock:getKeyIsExist("talk") then
				if delayTime ~= 0 then
					KNMsg:getInstance():flashShow("亲，你说话太快了，请隔5秒再发送哦。")
					return
				end
			else
				delayTime = 5
				KNClock:addTimeFun( "talk" , delayFun )
			end
			if not friendData and curType == "friend" then 
				KNMsg:getInstance():flashShow("请选择说话对象!")
				return
			end
			if textfield:getString() == "" or textfield:getString() == "点击输入信息"  then 
				KNMsg:getInstance():flashShow("没有输入内容")
			elseif textfield:getCharCount() > 135 then	--45个汉字
				KNMsg:getInstance():flashShow("输入内容过长无法发送")
			else
				if curType == "world" then
					if not isHorn then
						KNMsg:getInstance():flashShow("亲，你的喇叭不足，请至商城购买道具")
						return
					end
					HTTP:call("message" , "talk" , {
						content = textfield:getString()
					} , {
						success_callback = function(data)
							isHorn , hornTotleNum = DATA_Bag:getTypeNum( "prop" , "horn" )
							hornNum:setString( hornTotleNum )
							self:changeStauts(false)
						end})
					
				elseif curType == "gang" then
					HTTP:call("alliance" , "sendchat" , {
						content = textfield:getString()
					} , {
						success_callback = function()
							self:changeStauts(false)
						end
					})
					
				elseif curType == "friend" then
					HTTP:call("message" , "siliao" , {
						content = textfield:getString() , touid = friendData.uid
					} , {
						success_callback = function()
							self:changeStauts(false)
						end
					})
				end
			end
			
		end
	}):getLayer()
	self.inputLayer:addChild( send_btn )
	
	local beginY = 0
	self.inputLayer:setTouchEnabled(true)
	self.inputLayer:registerScriptTouchHandler( 
					function(event,x,y)
						if event == CCTOUCHBEGAN then
							beginY = y
						end
						
						if event == CCTOUCHENDED then
							if math.abs( beginY - y ) < 30 then	--如果是移动则输入入法不消失
								self:changeStauts(false)
							end
						end 
						return true 
					end , false , -130 )
					
	self:setState()
end
--输入框下信息切换
function M:setState()
	local isFriend = curType == "friend"
	findPlay:getLayer():setVisible( isFriend )
	findPlay:setEnable( isFriend )
	toText:setVisible( isFriend )
	haveHornNumSp:setVisible( curType == "world" )
	hornNum:setVisible( curType == "world" )
	hornNum:setVisible( curType == "world" )
end

return M